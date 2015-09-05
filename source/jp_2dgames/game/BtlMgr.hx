package jp_2dgames.game;

import jp_2dgames.game.gui.BtlUI;
import jp_2dgames.game.gui.BtlCmdUI;
import jp_2dgames.game.BtlCmdUtil.BtlCmd;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.Actor;
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

  Result;       // リザルト
  End;          // おしまい
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

  // 入力待ちとなるかどうか
  var _bKeyWait:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new(btlUI:BtlUI) {

    _player = ActorMgr.recycle(PartyGroup.Player, Global.getPlayerParam());
    var param = new Params();
    param.id = Global.getStage();
    _enemy = ActorMgr.recycle(PartyGroup.Enemy, param);

    // TODO:
    _player.setName("プレイヤー");
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

    // キー入力待ちのチェック
    switch(_state) {
      case State.Act, State.ActEnd:
        _bKeyWait = true;
      case State.BtlWin, State.BtlLose:
        _bKeyWait = true;
      default:
    }
  }

  /**
   * コマンド入力更新
   **/
  private function _procInputCommand():Void {
    var cmd:BtlCmd = BtlCmd.None;
    if(MyKey.press.A) {
      cmd = BtlCmd.Attack(0);
    }
    else if(MyKey.press.B) {
      cmd = BtlCmd.Attack(1);
    }
    else if(MyKey.press.X) {
      cmd = BtlCmd.Attack(2);
    }
    else if(MyKey.press.Y) {
      cmd = BtlCmd.Item(0);
    }
    else if(FlxG.keys.justPressed.B) {
      cmd = BtlCmd.Escape;
    }

    if(cmd != BtlCmd.None) {
      // コマンド実行
      _cbCommand(_player, cmd);
    }
  }

  /**
   * コマンド入力結果受け取り
   * @param actor 実行主体者
   * @param cmd   コマンド
   **/
  private function _cbCommand(actor:Actor, cmd:BtlCmd):Void {

    // コマンド設定
    actor.setCommand(cmd);

    // 敵のAIを設定
    ActorMgr.requestEnemyAI();

    // バトルUI消去
    FlxG.state.remove(_btlCmdUI);
    _btlCmdUI.kill();
    _btlCmdUI = null;

    // 行動順の決定
    _actorList = ActorMgr.getAlive();
    ArraySort.sort(_actorList, function(a:Actor, b:Actor) {
      return a.agi - b.agi;
    });

    // 行動開始
    _change(State.ActBegin);
  }

  private var _elapsed:Float = 0;
  /**
   * 更新
   **/
  public function proc():Void {

    if(_bKeyWait) {
      // キー入力待ち
      if(MyKey.press.A == false) {
        return;
      }
      // キーを入力した
      _bKeyWait = false;
    }

    switch(_state) {
      case State.None:
        // 何もしない

      case State.TurnStart:
        // ターン開始
        _btlCmdUI = new BtlCmdUI(_player, _cbCommand);
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
        var cmd = _actor.exec();
        if(cmd == BtlCmd.Escape) {
          // TODO: 逃走成功
          _change(State.Result);
        }
        else {
          _change(State.ActEnd);
        }

      case State.ActEnd:
        if(_actor.isActEnd()) {
          // 行動完了
          _actor.actEnd();
          // 死亡チェック
          _change(State.DeadCheck);
        }

      case State.DeadCheck:
        // 死亡チェック
        _procDeadCheck();

      case State.TurnEnd:
        // ターン終了
        ActorMgr.turnEnd();
        _change(State.TurnStart);

      case State.BtlWin:
        _change(State.Result);
      case State.BtlLose:
        _change(State.Result);

      case State.Result:
        // プレイヤーパラメータをグローバルに戻しておく
        Global.setPlayerHp(_player.hp);
        _change(State.End);

      case State.End:
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

  /**
   * 戦闘が終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }
}
