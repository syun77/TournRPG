package jp_2dgames.game.field;

import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.gui.InventoryUI;
import flixel.FlxG;
import flixel.util.FlxPoint;
import jp_2dgames.game.util.LineMgr;
import jp_2dgames.game.gui.UIMsg;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.state.FieldSubState;
import jp_2dgames.game.state.FieldState;

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

  // 状態
  var _state:State = State.Main;

  // 親
  var _flxState:FieldState;

  // 現在いるノード
  var _nowNode:FieldNode;

  // 経路描画
  var _lines:LineMgr;
  var _lines2:LineMgr;

  // プレイヤートークン
  var _player:FieldPlayer;

  // イベント管理
  var _eventMgr:FieldEventMgr;

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

    // マップの作成
    _nowNode = FieldNodeUtil.create();

    // プレイヤー
    _player = new FieldPlayer();
    _flxState.add(_player);

    // イベント管理
    _eventMgr = new FieldEventMgr(_flxState);

    // 経路描画
    _lines2 = new LineMgr(_flxState, LINE_MAX, MyColor.ASE_PINK);
    _lines = new LineMgr(_flxState, LINE_MAX, MyColor.ASE_LIME);

    // メッセージ
    var csv = new CsvLoader(Reg.PATH_CSV_MESSAGE);
    Message.createInstance(csv, _flxState);

    // アイテムメニュー
    var label = UIMsg.get(UIMsg.CMD_ITEM);
    var px = InventoryUI.BTN_CANCEL_X;
    var py = InventoryUI.BTN_CANCEL_Y + InventoryUI.BASE_OFS_Y + FlxG.height;
    var btnItem = new MyButton(px, py, label, function() {
      _flxState.openSubState(new FieldSubState());
    });
    trace(btnItem.x, btnItem.y);
    trace(InventoryUI.BTN_CANCEL_X, InventoryUI.BTN_CANCEL_Y);
    flxState.add(btnItem);
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
    _lines2.visible = false;

    // 経路描画
    for(n in _nowNode.reachableNodes) {
      _lines.drawFromNode(_nowNode, n);
    }

    if(selNode != null) {

      // 選択しているノードがある
      selNode.scale.set(1.5, 1.5);
      for(n in selNode.reachableNodes) {
        _lines2.drawFromNode(selNode, n);
      }

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
