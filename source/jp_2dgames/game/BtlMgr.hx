package jp_2dgames.game;

import jp_2dgames.game.PartyGroupUtil;
import haxe.ds.ArraySort;
import jp_2dgames.lib.MyKey;
import flixel.FlxG;

/**
 * 状態
 **/
private enum State {
  KeyInput;
  ActBegin;
  TurnEnd;
}

/**
 * バトル管理
 **/
class BtlMgr {

  var _player:Actor;
  var _enemy:Actor;

  var _state:State;

  var _actorList:Array<Actor> = null;

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

    _state = State.KeyInput;

    FlxG.watch.add(this, "_state");
  }

  /**
   * 更新
   **/
  public function proc():Void {
    switch(_state) {
      case State.KeyInput:
        if(MyKey.press.A) {
          _state = State.ActBegin;
          _actorList = ActorMgr.getAlive();
          ArraySort.sort(_actorList, function(a:Actor, b:Actor) {
            return b.agi - a.agi;
          });
        }
      case State.ActBegin:
        for(actor in _actorList) {
          actor.exec();
        }
        _state = State.TurnEnd;
      case State.TurnEnd:
        _state = State.KeyInput;
    }
  }
}
