package jp_2dgames.game;

/**
 * 状態
 **/
import jp_2dgames.lib.MyKey;
import flixel.FlxG;
private enum State {
  KeyInput;
  PlayerAct;
  EnemyAct;
  TurnEnd;
}

/**
 * バトル管理
 **/
class BtlMgr {

  var _player:Actor;
  var _enemy:Actor;

  var _state:State;

  /**
   * コンストラクタ
   **/
  public function new(btlUI:BtlUI) {
    _player = Actor.add();
    _enemy = Actor.add();

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
          _state = State.PlayerAct;
        }
      case State.PlayerAct:
        _enemy.damage(10);
        _state = State.EnemyAct;
      case State.EnemyAct:
        _player.damage(5);
        _state = State.TurnEnd;
      case State.TurnEnd:
        _state = State.KeyInput;
    }
  }
}
