package jp_2dgames.game.btl;

import jp_2dgames.game.actor.PartyMgr;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import jp_2dgames.game.gui.BtlInfoUI;
import jp_2dgames.game.field.FieldEffectUtil;
import jp_2dgames.game.btl.types.BtlEndResult;
import jp_2dgames.game.btl.types.BtlEndType;
import jp_2dgames.game.skill.SkillSlot;
import jp_2dgames.game.gui.MyButton2;
import jp_2dgames.game.btl.logic.BtlLogicMgr;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.btl.logic.BtlLogicPlayer;
import jp_2dgames.game.gui.BtlPlayerUI;
import jp_2dgames.game.gui.BtlCmdUI;
import jp_2dgames.game.btl.types.BtlCmd;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.btl.BtlGroupUtil;
import jp_2dgames.lib.Input;

/**
 * バトル起動パラメータ
 **/
class BtlMgrParam {
  public var party:PartyMgr;     // パーティ情報
  public var enemyGroupID:Int;   // 敵グループID
  public var effect:FieldEffect; // 地形効果

  public function new() {
    party = new PartyMgr();
    enemyGroupID = 0;
    effect = FieldEffect.None;
  }

}

/**
 * 状態
 **/
private enum State {
  None;         // なし

  TurnStart;    // ターン開始
  InputCmdNext; // コマンド入力チェック
  InputCmdWait; // コマンド入力待ち
  InputCmdEnd;  // コマンド入力終了

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

  var _state:State = State.None;
  var _statePrev:State = State.None;

  var _btlCmdUI:BtlCmdUI = null;

  // 再生中のバトル演出
  var _logicPlayer:BtlLogicPlayer = null;

  // リザルト管理
  var _result:BtlResult = null;

  // バトル終了理由
  var _btlEnd:BtlEndResult;
  public var btlEnd(get, never):BtlEndResult;
  private function get_btlEnd() {
    var npcIdx:Int = 0;
    // 生存者から探す
    ActorMgr.forEachAliveGroup(BtlGroup.Player, function(actor:Actor) {
      if(actor.isPlayer()) {
        _btlEnd.party.getPlayerParam().copy(actor.param);
      }
      else {
        _btlEnd.party.getNpcParam(npcIdx).copy(actor.param);
        npcIdx++;
      }
    });
    // 墓場から探す
    ActorMgr.forEachGrave(function(actor:Actor) {
      if(actor.group == BtlGroup.Player) {
        _btlEnd.party.getNpcParam(npcIdx).copy(actor.param);
        npcIdx++;
      }
    });

    return _btlEnd;
  }

  private var _flxState:FlxState;

  // 現在コマンド入力中のキャラ番号
  private var _commandIdx:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new(flxState:FlxState, param:BtlMgrParam) {

    _flxState = flxState;


    // 敵の生成
    BtlUtil.createEnemyGroup(param.enemyGroupID);

    // バトル情報Ui
    BtlInfoUI.create(_flxState);
    BtlInfoUI.setEffect(param.effect);

    // プレイヤーの生成
    var party = param.party;
    for(i in 0...party.countExists()) {
      var p:Params = null;
      if(i == PartyMgr.PLAYER_IDX) {
        p = party.getPlayerParam();
      }
      else {
        p = party.getNpcParam(i - PartyMgr.NPC_IDX_START);
      }
      var actor = ActorMgr.recycle(BtlGroup.Player, p);
      actor.copyParam(p);
      _createPlayer(i, actor);
    }

    // バトル地形
    _flxState.add(new BtlField());


    // バトル終了パラメータ
    _btlEnd = new BtlEndResult();

    // ターン開始
    _change(State.TurnStart);

    FlxG.watch.add(this, "_state");
    FlxG.watch.add(this, "_statePrev");
  }

  /**
   * プレイヤー生成
   **/
  private function _createPlayer(idx:Int, player:Actor):Void {
    // プレイヤーUI
    var ui = BtlPlayerUI.setPlayerID(idx, player.ID);

    player.x = FlxG.width/2;
    player.y = FlxG.height/2;
    player.x_ui = ui.x;
    player.y_ui = ui.y;
  }

  /**
   * 状態遷移
   **/
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
      var group = BtlGroup.Enemy;
      var target = ActorMgr.random(group);

      cmd = BtlCmd.Attack(BtlRange.One, target.ID);
    }

    if(cmd != BtlCmd.None) {
      // コマンド実行
      var player = ActorMgr.getPlayer();
      _cbCommand(player, cmd);
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

    // バトルUI消去
    _flxState.remove(_btlCmdUI);
    _btlCmdUI.vanish(_flxState);
    _btlCmdUI = null;

    // 次のコマンドチェック
    _change(State.InputCmdNext);
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
   * 更新・ターン開始
   **/
  private function _procTurnStart():Void {
    // コマンド入力チェックへ
    _commandIdx = -1;
    _change(State.InputCmdNext);
  }

  /**
   * 更新・次のコマンドチェック
   **/
  private function _procInputCmdNext():Bool {
    _commandIdx++;
    if(_commandIdx == 0) {
      // プレイヤー
      var player = ActorMgr.getPlayer();
      _btlCmdUI = new BtlCmdUI(_flxState, player, _cbCommand);
      _flxState.add(_btlCmdUI);

      // コマンド入力待ちする
      return true;
    }
    else {
      // NPC
      var idx = _commandIdx;
      var npc = ActorMgr.getNpc(idx);
      if(npc == null) {
        // コマンド入力終了
        return false;
      }
      else {
        _btlCmdUI = new BtlCmdUI(_flxState, npc, _cbCommand);
        _flxState.add(_btlCmdUI);

        // コマンド入力待ちする
        return true;
      }
    }

  }

  /**
   * 更新・コマンド入力終了
   **/
  private function _procInputCmdEnd():Void {

    // 敵のAIを設定
    ActorMgr.requestEnemyAI();

    // 演出リストの作成開始
    _change(State.LogicCreate);
  }

  /**
   * 更新・演出開始
   **/
  private function _procLogicBegin():Void {
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
  }

  /**
   * 更新・演出終了
   **/
  private function _procLogicEnd():Void {
    _btlEnd.type = _logicPlayer.getBtlEnd();

    switch(_btlEnd.type) {
      case BtlEndType.Escape:
        // 逃走した
        _change(State.Escape);

      case BtlEndType.Win:
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
      case BtlEndType.Lose:
        // バトル敗北
        _change(State.BtlLose);
      default:
        // 演出開始に戻る
        _change(State.LogicBegin);
    }
  }

  /**
   * 更新・リザルト待機
   **/
  public function _procResultWait():Void {
    // 次に進む
    var cbNext = function() {
      // バトル中のみ有効なパラメータを初期化
      var player = ActorMgr.getPlayer();
      if(player != null) {
        player.param.resetBattle();
      }
      _change(State.End);
    }

    if(_btlEnd.type == BtlEndType.Escape) {
      // 逃走時はそのまま終わる
      cbNext();
      return;
    }

    var px = FlxG.width/2 - MyButton2.WIDTH/2;
    var py = FlxG.height -128;
    var btn = new MyButton2(px, py, "NEXT", cbNext);
    _flxState.add(btn);

    _change(State.EndWait);

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
        _procTurnStart();

      case State.InputCmdNext:
        // コマンド入力チェック
        if(_procInputCmdNext()) {
          // まだ入力がある
          _change(State.InputCmdWait);
        }
        else {
          // 入力終了
          _change(State.InputCmdEnd);
        }

      case State.InputCmdWait:
        // コマンド入力待ち
        // カメラズームを戻す
        var d = FlxCamera.defaultZoom - FlxG.camera.zoom;
        FlxG.camera.zoom += (d * 0.1);
        // デバッグ用入力チェック
        _debugProcInputCommand();

      case State.InputCmdEnd:
        // コマンド入力終了
        _procInputCmdEnd();

      case State.LogicCreate:
        // ロジック生成
        _createLogic();

      case State.LogicBegin:
        // 演出開始
        _procLogicBegin();

      case State.LogicMain:
        // 演出実行
        _logicPlayer.update();
        if(_logicPlayer.isEnd()) {
          // 演出終了
          _change(State.LogicEnd);
        }

      case State.LogicEnd:
        // 演出終了チェック
        _procLogicEnd();


      case State.TurnEnd:
        // ターン終了
        ActorMgr.forEachAlive(function(act:Actor) {
          act.turnEnd();
        });
        BtlGlobal.nextTurn();
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

        // リザルト待機
        _procResultWait();

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
