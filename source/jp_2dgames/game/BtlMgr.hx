package jp_2dgames.game;

import jp_2dgames.game.PartyGroupUtil;
import haxe.ds.ArraySort;
import jp_2dgames.lib.MyKey;
import flixel.FlxG;

/**
 * 状態
 **/
private enum State {
  None;         // なし
  TurnStart;    // ターン開始
  InputCommand; // コマンド入力待ち
  ActBegin;     // 行動実行
  TurnEnd;      // ターン終了
}

/**
 * バトル管理
 **/
class BtlMgr {

  var _player:Actor;
  var _enemy:Actor;

  var _state:State = State.None;
  var _statePrev:State = State.None;

  var _actorList:Array<Actor> = null;
  var _btlCmdUI:BtlCmdUI = null;

  /**
   * コンストラクタ
   **/
  public function new(btlUI:BtlUI) {
    var p = new Params();
    p.agi = 5;
    _player = ActorMgr.recycleActor(PartyGroup.Player, p);
    p.agi = 10;
    _enemy = ActorMgr.recycleActor(PartyGroup.Enemy, p);

    // TODO:
    _player.setName("プレイヤー");
    _enemy.setName("敵");

    btlUI.setPlayerID(_player.ID);
    btlUI.setEnemyID(_enemy.ID);

    // ターン開始
    _change(State.TurnStart);

    FlxG.watch.add(this, "_state");
    FlxG.watch.add(this, "_statePrev");
  }

  private function _change(s:State):Void {
    _statePrev = _state;
    _state = s;
  }

  /**
   * コマンド入力結果受け取り
   **/
  private function _cbCommand(btnID:Int):Void {

    // バトルUI消去
    FlxG.state.remove(_btlCmdUI);
    _btlCmdUI.kill();
    _btlCmdUI = null;

    // 行動順の決定
    _actorList = ActorMgr.getAlive();
    ArraySort.sort(_actorList, function(a:Actor, b:Actor) {
      return b.agi - a.agi;
    });

    // 行動開始
    _change(State.ActBegin);
  }

  /**
   * 更新
   **/
  public function proc():Void {
    switch(_state) {
      case State.None:
        // 何もしない

      case State.TurnStart:
        // ターン開始
        _btlCmdUI = new BtlCmdUI(_cbCommand);
        FlxG.state.add(_btlCmdUI);
        _change(State.InputCommand);

      case State.InputCommand:
        // コマンド入力待ち

      case State.ActBegin:
        // 行動実行
        for(actor in _actorList) {
          actor.exec();
        }
        _change(State.TurnEnd);

      case State.TurnEnd:
        // ターン終了
        _change(State.TurnStart);
    }
  }
}
