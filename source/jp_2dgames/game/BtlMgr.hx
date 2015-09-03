package jp_2dgames.game;

import openfl._internal.aglsl.assembler.Part;
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

  // 行動
  ActBegin;     // 開始
  Act;          // 実行中
  ActEnd;       // 終了

  DeadCheck;    // 死亡チェック

  TurnEnd;      // ターン終了

  BtlWin;       // 勝利
  BtlLose;      // 敗北
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

  // 行動主体者
  var _actor:Actor = null;

  /**
   * コンストラクタ
   **/
  public function new(btlUI:BtlUI) {
    var p = new Params();
    p.agi = 5;
    _player = ActorMgr.recycle(PartyGroup.Player, p);
    p.agi = 10;
    _enemy = ActorMgr.recycle(PartyGroup.Enemy, p);

    // TODO:
    _player.setName("プレイヤー");
    _enemy.setName("敵");
    {
      var px = FlxG.width/2 - _enemy.width/2;
      var py = FlxG.height/2 - _enemy.height/2;
      _enemy.setDrawPosition(px, py);
    }

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
   * コマンド入力更新
   **/
  private function _procInputCommand():Void {
    var btnID = -1;
    if(MyKey.press.A) {
      btnID = BtlCmdUI.CMD_ATK1;
    }
    else if(MyKey.press.B) {
      btnID = BtlCmdUI.CMD_ATK2;
    }
    else if(MyKey.press.X) {
      btnID = BtlCmdUI.CMD_ATK3;
    }
    else if(MyKey.press.Y) {
      btnID = BtlCmdUI.CMD_ITEM;
    }

    if(btnID != -1) {
      _cbCommand(btnID);
    }
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

  private var _elapsed:Float = 0;
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
        _procInputCommand();

      case State.ActBegin:
        // 行動実行
        var bAllDone = true;
        for(actor in _actorList) {
          if(actor.isTurnEnd() == false) {
            _actor = actor;
            bAllDone = false;
          }
        }

        if(bAllDone) {
          // 全員行動完了
          _change(State.TurnEnd);
        }
        else {
          // 行動開始
          _actor.actBegin();
          _change(State.Act);
        }

      case State.Act:
        if(MyKey.press.A) {
          _actor.exec();
          _change(State.ActEnd);
        }

      case State.ActEnd:
        if(MyKey.press.A) {
          if(_actor.isActEnd()) {
            // 行動完了
            _actor.actEnd();
            // 死亡チェック
            _change(State.DeadCheck);
          }
        }

      case State.DeadCheck:
        // 死亡チェック
        _procDeadCheck();

      case State.TurnEnd:
        // ターン終了
        ActorMgr.turnEnd();
        _change(State.TurnStart);

      case State.BtlWin:
      case State.BtlLose:
    }
  }

  private function _procDeadCheck():Void {
    var actor = ActorMgr.searchDead();
    if(actor != null) {
      ActorMgr.moveDeadPool(actor);
      if(ActorMgr.countGroup(PartyGroup.Enemy) == 0) {
        // 敵が全滅
        Message.push2(Msg.BATTLE_WIN);
        _change(State.BtlWin);
        return;
      }
      if(ActorMgr.countGroup(PartyGroup.Player) == 0) {
        // 味方が全滅
        Message.push2(Msg.BATTLE_LOSE);
        _change(State.BtlLose);
        return;
      }
    }
    _actor = null;
    _change(State.ActBegin);
  }
}
