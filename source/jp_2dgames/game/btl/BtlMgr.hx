package jp_2dgames.game.btl;

import jp_2dgames.game.btl.logic.BtlLogicUtil;
import jp_2dgames.game.btl.logic.BtlLogicMgr;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.btl.logic.BtlLogicPlayer;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.gui.BtlUI;
import jp_2dgames.game.gui.BtlCmdUI;
import jp_2dgames.game.btl.types.BtlCmd;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.btl.BtlGroupUtil;
import haxe.ds.ArraySort;
import jp_2dgames.lib.Input;
import flixel.FlxG;

/**
 * 状態
 **/
private enum State {
  None;         // なし
  TurnStart;    // ターン開始
  InputCommand; // コマンド入力待ち

  LogicCreate; // 演出作成
  LogicBegin;  // 演出開始
  LogicMain;       // 演出中
  LogicEnd;    // 演出終了

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

  // 再生中のバトル演出
  var _logicPlayer:BtlLogicPlayer = null;

  // 入力待ちとなるかどうか
  var _bKeyWait:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new(btlUI:BtlUI) {

    _player = ActorMgr.recycle(BtlGroup.Player, Global.getPlayerParam());
    var param = new Params();
    param.id = Global.getStage();
    _enemy = ActorMgr.recycle(BtlGroup.Enemy, param);

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
  }

  /**
   * コマンド入力更新
   **/
  private function _procInputCommand():Void {
    var cmd:BtlCmd = BtlCmd.None;
    if(Input.press.A && FlxG.mouse.justPressed == false) {
      cmd = BtlCmd.Attack(BtlRange.One, 0);
    }
    else if(Input.press.B) {
      var item = Inventory.getItem(0);
      cmd = BtlCmd.Item(item, null, 0);
    }
    else if(Input.press.X) {
      var item = Inventory.getItem(0);
      cmd = BtlCmd.Item(item, null, 0);
    }
    else if(Input.press.Y) {
      var item = Inventory.getItem(0);
      cmd = BtlCmd.Item(item, null, 0);
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
      // 移動速度で降順ソート
      return a.agi - b.agi;
    });

    // 演出リストの作成開始
    _change(State.LogicCreate);
  }

  /**
   * ボトル演出のリスト作成
   **/
  private function _createEffect():Void {

    for(actor in _actorList) {
      var eft = BtlLogicUtil.create(actor);
      BtlLogicMgr.push(eft);
    }

    // 演出作成開始
    _change(State.LogicBegin);
  }

  /**
   * 更新
   **/
  public function proc():Void {

    if(_bKeyWait) {
      // キー入力待ち
      if(Input.press.A == false) {
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

      case State.LogicCreate:
        _createEffect();

      case State.LogicBegin:
        var logic = BtlLogicMgr.pop();
        if(logic == null) {
          // 再生する演出がなくなったのでおしまい
          _change(State.TurnEnd);
        }
        else {
          // 演出再生
          _logicPlayer = new BtlLogicPlayer(logic);
          _logicPlayer.start();
          _change(State.LogicMain);
        }

      case State.LogicMain:
        // 演出実行
        _logicPlayer.update();

        if(_logicPlayer.isEnd()) {
          // 演出終了
          _change(State.LogicEnd);
        }

      case State.LogicEnd:
        // 次の演出へ
        _change(State.LogicBegin);

      case State.DeadCheck:
        // 死亡チェック
        _procDeadCheck();

      case State.TurnEnd:
        // ターン終了
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
      if(ActorMgr.countGroup(BtlGroup.Enemy) == 0) {
        // 敵が全滅
        Message.push2(Msg.BATTLE_WIN);
        _change(State.BtlWin);
        return;
      }
      if(ActorMgr.countGroup(BtlGroup.Player) == 0) {
        // 味方が全滅
        Message.push2(Msg.BATTLE_LOSE);
        _change(State.BtlLose);
        return;
      }
    }
  }

  /**
   * 戦闘が終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }
}
