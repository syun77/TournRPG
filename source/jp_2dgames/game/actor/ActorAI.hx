package jp_2dgames.game.actor;
import flixel.util.FlxRandom;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.btl.types.BtlCmd;
import jp_2dgames.game.btl.BtlGroupUtil;
import jp_2dgames.lib.AdvScript;

/**
 * 攻撃対象
 **/
private enum AITarget {
  Random; // ランダム
}

/**
 * 敵のAI
 **/
class ActorAI {

  // 行動者自身
  var _actor:Actor;

  // スクリプト
  var _script:AdvScript;

  // 攻撃対象
  var _target:AITarget;

  // ログ出力
  var _bLog:Bool = false;
  public function setLog(b:Bool):Void {
    _bLog = b;
    _script.setLog(b);
  }

  // コマンド
  var _cmd:BtlCmd;
  public var cmd(get, never):BtlCmd;
  private function get_cmd() {
    return _cmd;
  }

  /**
   * コンストラクタ
   **/
  public function new(actor:Actor, script:String) {

    _actor = actor;

    var tbl = [
      "ACT_ATTACK" => _ACT_ATTACK,
      "ACT_SKILL"  => _ACT_SKILL,
      "SEL_RND"    => _SEL_RND,
      "LOT"        => _LOT,
      "LOG"        => _LOG,
    ];

    _script = new AdvScript(tbl, script);
  }

  /**
   * 実行
   **/
  public function exec():Void {
    // プログラムカウンタを初期化
    _script.resetPc();

    if(_bLog) {
      trace("---------------");
      trace('${_actor.name}');
    }

    // 終了するまで実行
    while(_script.isEnd() == false) {
      _script.update();
    }
  }

  /**
   * 通常攻撃
   **/
  private function _ACT_ATTACK(param:Array<String>):Int {
    if(_bLog) {
      trace("[AI] Action Attack");
    }

    switch(_target) {
      case AITarget.Random:
        var group = BtlGroupUtil.getAgaint(_actor.group);
        var target = ActorMgr.random(group);
        _cmd = BtlCmd.Attack(BtlRange.One, target.ID);
    }

    return AdvScript.RET_CONTINUE;
  }

  /**
   * スキル発動
   **/
  private function _ACT_SKILL(param:Array<String>):Int {
    var p0 = _script.popStack();

    var skillID = p0;
    if(_bLog) {
      trace('[AI] Action Skill(${skillID})');
    }

    switch(_target) {
      case AITarget.Random:
        var group = BtlGroupUtil.getAgaint(_actor.group);
        var target = ActorMgr.random(group);
        _cmd = BtlCmd.Skill(skillID, BtlRange.One, target.ID);
    }

    return AdvScript.RET_CONTINUE;
  }

  /**
   * ランダム選択
   **/
  private function _SEL_RND(param:Array<String>):Int {
    if(_bLog) {
      trace("[AI] Target Random");
    }

    _target = AITarget.Random;

    return AdvScript.RET_CONTINUE;
  }

  /**
   * 抽選
   **/
  private function _LOT(param:Array<String>):Int {
    var p0 = _script.popStack();
    if(_bLog) {
      trace('[AI] Lottory (${p0})');
    }

    if(FlxRandom.chanceRoll(p0)) {
      // 成功
      _script.pushStack(1);
    }
    else {
      // 失敗
      _script.pushStack(0);
    }

    return AdvScript.RET_CONTINUE;
  }

  private function _LOG(param:Array<String>):Int {
    var p0 = _script.popStack();
    var prev = _bLog;
    _bLog = (p0 != 0);
    var sysLog = (p0 == 2);
    _script.setLog(sysLog);
    if(prev || _bLog) {
      trace('[AI] LOG ${p0}');
    }

    return AdvScript.RET_CONTINUE;
  }
}
