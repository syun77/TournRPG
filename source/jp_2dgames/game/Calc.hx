package jp_2dgames.game;

/**
 * 計算式
 **/
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.skill.SkillType;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.actor.Actor;
import flixel.util.FlxRandom;
class Calc {

  // 最大ダメージ
  public static inline var MAX_DAMAGE:Int = 99999;

  // ミス時のダメージ値
  public static inline var MISS_DAMAGE:Int = -1;

  // 基本攻撃力
  static inline var BASE_ATK:Int = 5;

  // ダメージのランダム補正係数
  static inline var DAMAGE_RATIO = 0.125;

  /**
   * 命中判定
   * @return 回避できたらtrue
   **/
  public static function checkHit(act:Actor, target:Actor):Bool {

    // 基本命中率
    var base:Float = 93.7;
    var rnd:Float  = base;
    if(act.badstatus == BadStatus.Blind) {
      // 攻撃側が暗闇状態なので命中率低下
      rnd = base - 50;
    }

    if(rnd < 1) {
      rnd = 1;
    }
    if(rnd > 99) {
      rnd = 99;
    }

    if(FlxRandom.chanceRoll(rnd)) {
      // 命中した
      return true;
    }

    // 回避した
    return false;
  }

  private static function _clamp(val:Float):Int {

    var ret:Float = val;

    if(ret <= 0) {
      // 0ダメージはランダムで1〜3ダメージ
      ret = FlxRandom.intRanged(1, 3);
    }
    else {
      // ランダムで変動
      var d = val * FlxRandom.floatRanged(-DAMAGE_RATIO, DAMAGE_RATIO);
      if(Math.abs(d) < 3) {
        // 3より小さい場合は+1〜3する
        ret += FlxRandom.intRanged(1, 3);
      }
      else {
        ret += d;
        if(ret > MAX_DAMAGE) {
          // 最大ダメージ量を超えないようにする
          ret = MAX_DAMAGE;
        }
      }
    }

    return Math.ceil(ret);
  }

  private static function _getAtk(act:Actor):Int {
    if(act.group == BtlGroup.Player) {
      var weapon = Inventory.getWeapon();
      return ItemUtil.getAtk(weapon);
    }
    else {
      return act.str * 2;
    }
  }
  private static function _getDef(act:Actor):Int {
    if(act.group == BtlGroup.Player) {
      var armor = Inventory.getArmor();
      return ItemUtil.getDef(armor);
    }
    else {
      return act.vit * 2;
    }
  }

  /**
   * ダメージ計算式
   * @return ダメージ量。回避された場合は「-1」
   **/
  public static function damage(act:Actor, target:Actor, power_skill:Int=0):Int {

    if(checkHit(act, target) == false) {
      // 外れ
      return MISS_DAMAGE;
    }

    // 力
    var str = act.str;
    // 耐久力
    var vit = target.vit;
    // 攻撃力
    var atk = _getAtk(act);
    // 防御力
    var def = _getDef(target);

    // 威力
    var power = str + (atk * 0.4) + BASE_ATK;
    if(power_skill > 0) {
      power = power_skill;
    }

    // 力係数 (基礎体力の差)
    var str_rate = Math.pow(1.02, str - vit);

    // 威力係数 (装備アイテムの差)
    var power_rate = Math.pow(1.015, atk - def);

    // 攻撃力アップ係数
    var buffAtk_rate = Math.pow(1.5, act.buffAtk);
    // 守備力アップ係数
    var buffDef_rate = Math.pow(0.5, act.buffDef);

//    trace('power: ${power} str_rate:${str_rate} pow_rate:${power_rate}');

    // ダメージ量を計算
    var val:Float = (power * str_rate * power_rate) * buffAtk_rate * buffDef_rate;

    return _clamp(val);
  }

  /**
   * スキルによるダメージ値を計算する
   **/
  public static function damageSkill(skillID:Int, act:Actor, target:Actor):Int {

    var val:Float = 0;

    var type = SkillUtil.toType(skillID);
    switch(type) {
      case SkillType.AtkPhyscal:
        // 物理攻撃
        if(checkHit(act, target) == false) {
          // 外れ
          return MISS_DAMAGE;
        }

        // 威力
        var power = SkillUtil.getParam(skillID, "pow") * 0.2;
        val = damage(act, target, Std.int(power));

      case SkillType.AtkMagical:
        // 魔法攻撃
        if(checkHit(act, target) == false) {
          // 外れ
          return MISS_DAMAGE;
        }

        // 攻撃側の魔力
        var mag1 = act.mag;
        // 対象側の魔力
        var mag2 = target.mag;
        // 攻撃力
        var atk = SkillUtil.getParam(skillID, "pow") * 0.2;
        // 防御力
        var def = _getDef(target);

        // 威力
        var power = atk + (mag1 * 0.4) + BASE_ATK;
        // 真係数
        var mag_rate = Math.pow(1.02, mag1 - mag2);
        // 威力係数
        var power_rate = Math.pow(1.015, atk - mag2 - def);

//        trace('power: ${power} mag_rate:${mag_rate} pow_rate:${power_rate}');

        // ダメージ量を計算
        val = (power * mag_rate * power_rate);

      default:
        throw "未実装のスキル種別: " + type;
    }

    return _clamp(val);
  }

  /**
   * 逃走チェック
   **/
  public static function isEscape(playerAGI:Int, enemyAGI:Int):Bool {

    var agi_ratio = Math.pow(1.02, playerAGI - enemyAGI);
    var rnd = 70 * agi_ratio;
    if(rnd > 99) {
      rnd = 99;
    }
    return FlxRandom.chanceRoll(rnd);
  }

  /**
   * バステ回復チェック
   **/
  public static function cureBadstatus(actor:Actor):Bool {
    var base = BadStatusUtil.getCureBaseRatio(actor.badstatus);
    if(base == 0) {
      // 回復しない
      return false;
    }

    if(actor.badstatusTurn == 0) {
      // 初回ターンでは回復しない
      return false;
    }

    var rnd = base + (10 * actor.badstatusTurn);
    return FlxRandom.chanceRoll(rnd);
  }

  /**
   * HP回復値
   **/
  public static function recoverHp(actor:Actor, val:Int):Int {
    var base:Int = 10;
    var ret = base + (val * actor.mag * 0.2);

    return Std.int(ret);
  }
}
