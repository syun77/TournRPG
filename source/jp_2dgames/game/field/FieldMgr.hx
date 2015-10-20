package jp_2dgames.game.field;

import jp_2dgames.game.state.ShopState;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import flixel.text.FlxText;
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
  Shop;   // ショップ表示中

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

  // 次のフロアに進むボタン
  var _btnNextFloor:MyButton;

  // ショップボタン
  var _btnShop:MyButton;

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

  /**
   * コンストラクタ
   **/
  public function new(flxState:FieldState) {
    _flxState = flxState;

    FlxG.watch.add(this, "_state");

    // 背景
    var bg = new FlxSprite().loadGraphic(Reg.getBackImagePath(1));
    bg.color = FlxColor.SILVER;
    _flxState.add(bg);

    // ノード管理作成
    FieldNode.createParent(_flxState);

    // F.O.E.
    FieldFoe.createParent(_flxState);

    // マップの作成
    if(Global.isLoad()) {
      // ロードしたデータを使う

      // ノードをロード
      TmpFieldNode.copyToFieldNode();
      TmpFieldNode.destroy();
      _nowNode = FieldNode.getStartNode();

      // F.O.E.をロード
      TmpFieldFoe.copyToFieldFoe();
      TmpFieldFoe.destroy();

      // ロード終了
      Global.setLoadFlag(false);
    }
    else {
      // 新規作成
      _nowNode = FieldNodeUtil.create();
      // 開始地点を踏破済みにしておく
      _nowNode.setFoot(true);
    }

    // 経路描画
    _createWayLine(bg);

    // TODO: F.O.E.をひとまず出してみる
    FieldNode.forEachAlive(function(n:FieldNode) {
      if(n.evType == FieldEvent.None) {
        FieldFoe.add(n.ID, 6);
      }
    });

    // TODO: ショップをひとまず配置
    FieldNode.forEachAlive(function(n:FieldNode) {
      if(n.evType == FieldEvent.Enemy) {
        n.setEventType(FieldEvent.Shop);
      }
    });

    // プレイヤー
    _player = new FieldPlayer();
    _flxState.add(_player);

    // Actor情報を生成
    _actor = new Actor(0);
    _actor.init(BtlGroup.Player, Global.getPlayerParam());
    _actor.setName(Global.getPlayerName());

    // 移動可能な経路を表示
    _lines = new LineMgr(_flxState, LINE_MAX, MyColor.ASE_LIME);
    _openNodes();

    // イベント管理
    _eventMgr = new FieldEventMgr(_flxState);

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
    {
      var label = UIMsg.get(UIMsg.MENU);
      var px = InventoryUI.BTN_CANCEL_X;
      _btnMenu = new MyButton(px, 0, label, function() {
        _hideUI();
        _flxState.openSubState(new FieldSubState(_actor, _charaUI, function() {
          // サブメニューを閉じたときに呼び出す関数
          _appearUI();
        }));
      });
      flxState.add(_btnMenu);
    }

    // 次のフロアに進むボタン
    {
      var label = UIMsg.get(UIMsg.NEXT_FLOOR);
      var px = InventoryUI.BTN_NEXTFLOOR_X;
      _btnNextFloor = new MyButton(px, 0, label, function() {
        _hideUI();
        // 次のフロアに進む
        _gotoNextFloor();
      });
      flxState.add(_btnNextFloor);
    }

    // ショップボタン
    {
      var label = UIMsg.get(UIMsg.SHOP);
      var px = InventoryUI.BTN_SHOP_X;
      _btnShop = new MyButton(px, 0, label, function() {
        _hideUI();
        // ショップを表示
        _flxState.openSubState(new ShopState(_cbShopEnd));
        _state = State.Shop;
      });
      flxState.add(_btnShop);
    }

    // UI出現
    _appearUI();
  }

  /**
   * 経路の線を生成する
   **/
  private function _createWayLine(bg:FlxSprite):Void {

    var ls:LineStyle = {color:0x40FFFFFF, thickness:0};
    FieldNodeUtil.drawReachableWay(function(n1:FieldNode, n2:FieldNode) {
      FlxSpriteUtil.drawLine(bg, n1.xcenter, n1.ycenter, n2.xcenter, n2.ycenter, ls);
    });
  }

  /**
   * UI非表示
   **/
  private function _hideUI():Void {
    _btnMenu.visible      = false;
    _btnNextFloor.visible = false;
    _btnShop.visible      = false;
    FieldNode.setVisible(false);
    _lines.visible = false;
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

    // 次のフロアに進むボタン
    _appearUINextFloor();

    // ショップボタン
    _appearUIShop();

    FieldNode.setVisible(true);
    _lines.visible = true;
  }

  /**
   * 次のフロアへ進むUIを表示する
   **/
  private function _appearUINextFloor():Void {
    var py = InventoryUI.BTN_CANCEL_Y + InventoryUI.BASE_OFS_Y + FlxG.height;
    _btnNextFloor.y = FlxG.height;
    FlxTween.tween(_btnNextFloor, {y:py}, 0.5, {ease:FlxEase.expoOut});

    // ゴールにいるときだけ表示
    _btnNextFloor.visible = _nowNode.isGoal();
  }

  /**
   * ショップUIを表示する
   **/
  private function _appearUIShop():Void {
    var py = InventoryUI.BTN_CANCEL_Y + InventoryUI.BASE_OFS_Y + FlxG.height;
    _btnShop.y = FlxG.height;
    FlxTween.tween(_btnShop, {y:py}, 0.5, {ease:FlxEase.expoOut});

    // ショップにいるときだけ表示
    _btnShop.visible = _nowNode.isShop();
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

      case State.Shop:

      case State.End:
        // おしまい
    }

    // メニューボタンの更新
    switch(_state) {
      case State.Main:
        _btnMenu.enable = true;
      default:
        _btnMenu.enable = false;
        _btnNextFloor.visible = false;
        _btnShop.visible = false;
    }
  }

  static var count:Int = 1;

  /**
   * 更新・メイン
   **/
  private function _updateMain():Void {

    // プレイヤーの位置を設定
    _player.setPositionFromNode(_nowNode);

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
      if(node.isStartFlag()) {
        // スタート地点は選べない
        return;
      }

      if(node.overlapsMouse()) {
        // 選択した
        selNode = node;
      }
    });


    if(selNode != null) {

      // 選択しているノードがある
      selNode.scale.set(1.5, 1.5);

      if(FlxG.mouse.justPressed) {

        // 移動先を選択した
        // 元のノードは何もない状態にする
        _nowNode.setEventType(FieldEvent.None);

        selNode.scale.set(1, 1);

        // 経路をいったん消す
        _lines.visible = false;

        // 選択したノードに向かって移動する
        _state = State.Moving;
        _player.moveTowardNode(selNode, function() {
          // イベント実行
          _state = State.Event;

          // F.O.E.との接触チェック
          var foe = FieldFoe.searchFromNodeID(selNode.ID);
          if(foe != null) {
            // F.O.E.とのバトル開始
            _eventMgr.startBattle(foe);
          }
          else {
            _eventMgr.start(selNode.evType);
          }
          // 開始ノードに設定
          FieldNode.setStartNode(selNode);
          _nowNode = selNode;

          // 踏破した
          _nowNode.setFoot(true);
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

        // 移動可能なノードを開く
        _openNodes();

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

      case FieldEventMgr.RET_GOAL:
        // ゴール
        _openNodes();
        // 次のフロアに進むボタンを表示
        _appearUINextFloor();
        // メイン処理に戻る
        _state = State.Main;

      case FieldEventMgr.RET_SHOP:
        // ショップ
        _openNodes();
        // ショップボタンを表示
        _appearUIShop();
        // メイン処理に戻る
        _state = State.Main;
    }
  }

  /**
   * ショップ終了時に呼び出す関数
   **/
  private function _cbShopEnd():Void {
    // ショップ終わり
    _state = State.Main;

    // UI表示
    _appearUI();
  }

  /**
   * ノードを開く
   **/
  private function _openNodes():Void {
    // すべてを移動不可にする
    FieldNode.forEachAlive(function(n:FieldNode) {
      n.reachable = false;
    });
    _nowNode.openNodes();

    // 経路描画
    // いったん非表示
    _lines.visible = false;
    for(n in _nowNode.reachableNodes) {
      _lines.drawFromNode(_nowNode, n);
    }
  }

  /**
   * 次のフロアに進む
   **/
  private function _gotoNextFloor():Void {
    // 次のステージに進む
    _resultCode = RET_NEXTSTAGE;
    _state = State.End;
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }
}
