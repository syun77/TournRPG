package jp_2dgames.game.field;

import flixel.text.FlxText;
import jp_2dgames.lib.RectLine;
import jp_2dgames.game.gui.BtlUI;
import jp_2dgames.game.gui.BtlCharaUI;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.Actor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxPoint;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.gui.UIMsg;
import jp_2dgames.game.util.LineMgr;
import jp_2dgames.game.state.FieldSubState;
import jp_2dgames.game.state.FieldState;
import jp_2dgames.lib.CsvLoader;

/**
 * 状態
 **/
private enum State {
  Main;   // メイン
  Moving; // 移動中
  Event;  // イベント実行中

  End;    // 終了
}

/**
 * フィールド管理
 **/
class FieldMgr {

  // 戻り値
  public static inline var RET_NONE:Int      = 0;
  public static inline var RET_NEXTSTAGE:Int = 1;
  public static inline var RET_GAMEOVER:Int  = 2;

  // 点線の最大数
  static inline var LINE_MAX:Int = 8;

  // 座標
  static inline var TXT_FLOOR_X:Int = 8;
  static inline var TXT_FLOOR_Y:Int = BtlUI.CHARA_Y + BtlCharaUI.HEIGHT + 4;

  // 状態
  var _state:State = State.Main;

  // 親
  var _flxState:FieldState;

  // 現在いるノード
  var _nowNode:FieldNode;

  // 経路描画
  var _lines:LineMgr;

  // プレイヤートークン
  var _player:FieldPlayer;

  // イベント管理
  var _eventMgr:FieldEventMgr;

  // メニューボタン
  var _btnMenu:MyButton;

  // Actor情報
  var _actor:Actor;

  // キャラUI
  var _charaUI:BtlCharaUI;

  // フロア数
  var _txtFloor:FlxText;

  // 戻り値
  var _resultCode:Int = RET_NONE;
  public var resultCode(get, never):Int;
  private function get_resultCode() {
    return _resultCode;
  }

  // 経路の線
  var _lineList:List<RectLine>;

  /**
   * コンストラクタ
   **/
  public function new(flxState:FieldState) {
    _flxState = flxState;

    // マップの作成
    if(Global.isLoad()) {
      // ロードしたデータを使う
      TmpFieldNode.copyToFieldNode();
      TmpFieldNode.destroy();
      _nowNode = FieldNode.getStartNode();
      _nowNode.openNodes();
      // ロード終了
      Global.setLoadFlag(false);
    }
    else {
      // 新規作成
      _nowNode = FieldNodeUtil.create();
    }

    // 経路描画
    _lineList = new List<RectLine>();
    createWayLine();

    // プレイヤー
    _player = new FieldPlayer();
    _flxState.add(_player);

    // Actor情報を生成
    _actor = new Actor(0);
    _actor.init(BtlGroup.Player, Global.getPlayerParam());
    _actor.setName(Global.getPlayerName());

    // イベント管理
    _eventMgr = new FieldEventMgr(_flxState);

    // 経路描画
    _lines = new LineMgr(_flxState, LINE_MAX, MyColor.ASE_LIME);

    // UI表示
    _charaUI = new BtlCharaUI(0, BtlUI.CHARA_Y, _actor);
    _flxState.add(_charaUI);

    // フロア数
    _txtFloor = new FlxText(TXT_FLOOR_X, TXT_FLOOR_Y);
    _txtFloor.text = 'Floor: ${Global.getFloor()}';
    _txtFloor.setBorderStyle(FlxText.BORDER_SHADOW);
    _flxState.add(_txtFloor);

    // メッセージ
    var csv = new CsvLoader(Reg.PATH_CSV_MESSAGE);
    Message.createInstance(csv, _flxState);

    // サブメニュー呼び出しボタン
    var label = UIMsg.get(UIMsg.MENU);
    var px = InventoryUI.BTN_CANCEL_X;
    _btnMenu = new MyButton(px, 0, label, function() {
      _btnMenu.visible = false;
      _flxState.openSubState(new FieldSubState(_actor, _charaUI, function() {
        // サブメニューを閉じたときに呼び出す関数
        _appearUI();
      }));
    });
    flxState.add(_btnMenu);

    // UI出現
    _appearUI();
  }

  /**
   * 経路の線を生成する
   **/
  public function createWayLine():Void {

    // 登録済みの線を消す
    for(line in _lineList) {
      _flxState.remove(line);
    }
    _lineList.clear();

    FieldNodeUtil.drawReachableWay(function(n1:FieldNode, n2:FieldNode) {
      var line = new RectLine(LINE_MAX, MyColor.ASE_WHITE);
      line.drawLine(n1.xcenter, n1.ycenter, n2.xcenter, n2.ycenter);
      line.alpha = 0.2;
      _lineList.add(line);
    });

    for(line in _lineList) {
      _flxState.add(line);
    }
  }

  /**
   * UI出現
   **/
  private function _appearUI():Void {

    // キャラUI
    {
      var py = BtlUI.CHARA_Y;
      _charaUI.y = -48;
      FlxTween.tween(_charaUI, {y:py}, 0.5, {ease:FlxEase.expoOut});
    }

    // サブメニューボタン
    {
      var py = InventoryUI.BTN_CANCEL_Y + InventoryUI.BASE_OFS_Y + FlxG.height;
      _btnMenu.y = FlxG.height;
      _btnMenu.visible = true;
      FlxTween.tween(_btnMenu, {y:py}, 0.5, {ease:FlxEase.expoOut});
    }
  }

  /**
   * 更新
   **/
  public function proc():Void {

    switch(_state) {
      case State.Main:
        _updateMain();

      case State.Moving:
        _updateMoving();

      case State.Event:
        _updateEvent();

      case State.End:
        // おしまい
    }

    // メニューボタンの更新
    switch(_state) {
      case State.Main:
        _btnMenu.enable = true;
      default:
        _btnMenu.enable = false;
    }
  }

  static var count:Int = 1;

  /**
   * 更新・メイン
   **/
  private function _updateMain():Void {

    // プレイヤーの位置を設定
    _player.setPositionFromNode(_nowNode);

    var pt = FlxPoint.get(FlxG.mouse.x, FlxG.mouse.y);
    var selNode:FieldNode = null;
    FieldNode.forEachAlive(function(node:FieldNode) {
      node.scale.set(1, 1);

      #if mobile
      if(FlxG.mouse.pressed == false) {
        // タップしていない場合は判定不要
        return;
      }
      #end

      if(node.reachable == false) {
        // 移動できないところは選べない
        return;
      }
      if(node.evType == FieldEvent.Start) {
        // スタート地点は選べない
        return;
      }

      if(node.overlapsPoint(pt)) {
        // 選択した
        selNode = node;
      }
    });


    // いったん非表示
    _lines.visible = false;

    // 経路描画
    for(n in _nowNode.reachableNodes) {
      _lines.drawFromNode(_nowNode, n);
    }

    if(selNode != null) {

      // 選択しているノードがある
      selNode.scale.set(1.5, 1.5);

      if(FlxG.mouse.justPressed) {

        // 移動先を選択した
        // 元のノードは何もない状態にする
        _nowNode.setEventType(FieldEvent.None);

        selNode.scale.set(1, 1);

        // 選択したノードに向かって移動する
        _state = State.Moving;
        _player.moveTowardNode(selNode, function() {
          // イベント実行
          _state = State.Event;
          _eventMgr.start(selNode.evType);
          selNode.setEventType(FieldEvent.Start);
          _nowNode = selNode;
        });
      }
    }
  }

  /**
   * 更新・移動中
   **/
  private function _updateMoving():Void {
  }

  /**
   * 更新・イベント
   **/
  private function _updateEvent():Void {
    _eventMgr.proc();
    if(_eventMgr.isEnd() == false) {
      return;
    }

    switch(_eventMgr.resultCode) {
      case FieldEventMgr.RET_NONE:
        // 探索を続ける

        // すべてを移動不可にする
        FieldNode.forEachAlive(function(n:FieldNode) {
          n.reachable = false;
        });
        _nowNode.openNodes();

        if(_eventMgr.isBtlEnd()) {
          // バトル後のパラメータを反映
          _actor.init(BtlGroup.Player, Global.getPlayerParam());
          // UI表示
          _appearUI();
        }

        // メイン処理に戻る
        _state = State.Main;

      case FieldEventMgr.RET_GAMEOVER:
        // ゲームオーバー
        _resultCode = RET_GAMEOVER;
        _state = State.End;

      case FieldEventMgr.RET_NEXTSTAGE:
        // 次のステージに進む
        _resultCode = RET_NEXTSTAGE;
        _state = State.End;
    }
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }
}
