package jp_2dgames.game.btl;

import jp_2dgames.game.skill.SkillSlot;
import jp_2dgames.game.gui.MyButton2;
import flixel.FlxState;
import flixel.FlxCamera;
import jp_2dgames.game.item.ItemData;
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
import jp_2dgames.lib.Input;
import flixel.FlxG;

/**
 * 状態
 **/
private enum State {
  None;         // なし

  TurnStart;    // ターン開始
  InputCommand; // コマンド入力待ち

  LogicCreate;  // 演出作成
  LogicBegin;   // 演出開始
  LogicMain;    // 演出中
  LogicEnd;     // 演出終了

  TurnEnd;      // ターン終了

  BtlWin;       // 勝利
  BtlLose;      // 敗北
  Escape;       // 逃走成功

  Result;       // リザルト
  ResultItem;   // アイテムの取捨選択
  ResultWait;   // リザルト・ボタン入力待ち
  EndWait;      // 終了待ち
  End;          // おしまい
}

/**
 * バトル管理
 **/
class BtlMgr {

  // 敵出現の最大数
  public static var ENEMY_APPEAR_MAX:Int = 5;

  var _player:Actor;

  var _state:State = State.None;
  var _statePrev:State = State.None;

  var _btlCmdUI:BtlCmdUI = null;

  // 再生中のバトル演出
  var _logicPlayer:BtlLogicPlayer = null;

  // リザルト管理
  var _result:BtlResult = null;

  // バトル終了理由
  var _btlEnd:Int = BtlLogicPlayer.BTL_END_NONE;
  public var btlEnd(get, never):Int;
  private function get_btlEnd() {
    return _btlEnd;
  }

  private var _flxState:FlxState;

  /**
   * コンストラクタ
   **/
  public function new(flxState:FlxState) {

    _flxState = flxState;

    // プレイヤーの生成
    _player = ActorMgr.recycle(BtlGroup.Player, Global.getPlayerParam());
    _player.setName(Global.getPlayerName());

    // 敵の生成
    BtlUtil.createEnemyGroup(Global.getEnemyGroup());

    BtlUI.setPlayerID(0, _player.ID);

    _player.x = FlxG.width/2;
    _player.y = FlxG.height/2;

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
  private function _debugProcInputCommand():Void {
    var cmd:BtlCmd = BtlCmd.None;
    if(Input.press.A && FlxG.mouse.justPressed == false) {
      // TODO: 相手グループをランダム攻撃
      var group = BtlGroupUtil.getAgaint(_player.group);
      var target = ActorMgr.random(group);

      cmd = BtlCmd.Attack(BtlRange.One, target.ID);
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
      cmd = BtlCmd.Escape(true);
    }

    if(cmd != BtlCmd.None) {
      // コマンド実行
      _cbCommand(_player, cmd);
    }
  }

  /**
   * コマンド入力結果受け取り
   * @param actor 実行主体者
   * @param type   コマンド
   **/
  private function _cbCommand(actor:Actor, cmd:BtlCmd):Void {

    // コマンド設定
    actor.setCommand(cmd);

    // 敵のAIを設定
    ActorMgr.requestEnemyAI();

    // バトルUI消去
    _flxState.remove(_btlCmdUI);
    _btlCmdUI.vanish(_flxState);
    _btlCmdUI = null;

    // 演出リストの作成開始
    _change(State.LogicCreate);
  }

  /**
   * バトル演出のリスト作成
   **/
  private function _createLogic():Void {

    BtlLogicMgr.createLogic();

    // 演出作成開始
    _change(State.LogicBegin);
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
        _btlCmdUI = new BtlCmdUI(_flxState, _player, _cbCommand);
        _flxState.add(_btlCmdUI);
        _change(State.InputCommand);

      case State.InputCommand:
        // コマンド入力待ち
        // カメラズームを戻す
        var d = FlxCamera.defaultZoom - FlxG.camera.zoom;
        FlxG.camera.zoom += (d * 0.1);
        // デバッグ用入力チェック
        _debugProcInputCommand();

      case State.LogicCreate:
        // ロジック生成
        _createLogic();

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
        _btlEnd = _logicPlayer.getBtlEnd();

        switch(_btlEnd) {
          case BtlLogicPlayer.BTL_END_ESCAPE:
            // 逃走した
            _change(State.Escape);
          case BtlLogicPlayer.BTL_END_WIN:
            // バトル勝利
            // HP/MPの自動回復
            var win_hp = SkillSlot.getBattleEndRecoveryHp();
            var win_mp = SkillSlot.getBattleEndRecoveryMp();
            if(win_hp > 0) {
              ActorMgr.forEachAliveGroup(BtlGroup.Player, function(act:Actor) {
                act.recoverHp(win_hp);
              });
            }
            if(win_mp > 0) {
              ActorMgr.forEachAliveGroup(BtlGroup.Player, function(act:Actor) {
                act.recoverMp(win_mp);
              });
            }
            _change(State.BtlWin);
          case BtlLogicPlayer.BTL_END_LOSE:
            // バトル敗北
            _change(State.BtlLose);
          default:
            // 演出開始に戻る
            _change(State.LogicBegin);
        }

      case State.TurnEnd:
        // ターン終了
        ActorMgr.forEachAlive(function(act:Actor) {
          act.turnEnd();
        });
        _change(State.TurnStart);

      case State.BtlWin:
        // アイテム獲得
        _change(State.Result);
      case State.BtlLose:
        _change(State.ResultWait);
      case State.Escape:
        _change(State.ResultWait);

      case State.Result:
        // リザルト
        _result = new BtlResult(_flxState);
        _change(State.ResultItem);

      case State.ResultItem:
        _result.update();
        if(_result.isEnd()) {
          // リザルトへ
          _change(State.ResultWait);
        }

      case State.ResultWait:

        // 次に進む
        var cbNext = function() {
          // バフ・デバフを初期化
          _player.param.resetBuf();
          // プレイヤーパラメータをグローバルに戻しておく
          Global.setPlayerParam(_player.param);
          _change(State.End);
        }

        if(_btlEnd == BtlLogicPlayer.BTL_END_ESCAPE) {
          // 逃走時はそのまま終わる
          cbNext();
          return;
        }

        var px = FlxG.width/2 - MyButton2.WIDTH/2;
        var py = FlxG.height -128;
        var btn = new MyButton2(px, py, "NEXT", cbNext);
        _flxState.add(btn);

        _change(State.EndWait);


      case State.EndWait:
        // 終了待ち

      case State.End:
    }
  }

  /**
   * 戦闘が終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }
}
