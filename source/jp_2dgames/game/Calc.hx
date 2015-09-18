package jp_2dgames.game;

/**
 * 計算式
 **/
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
    if(FlxRandom.chanceRoll(93.7)) {
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

  private static function _getEnemyAtk(act:Actor):Int {
    return act.str * 2;
  }
  private static function _getEnemyDef(act:Actor):Int {
    return act.vit * 2;
  }

  /**
   * ダメージ計算式
   * @return ダメージ量。回避された場合は「-1」
   **/
  public static function damage(act:Actor, target:Actor):Int {

    if(checkHit(act, target) == false) {
      // 外れ
      return MISS_DAMAGE;
    }

    // 力
    var str = act.str;
    // 耐久力
    var vit = target.vit;
    // 攻撃力
    var atk = 0;
    if(act.group == BtlGroup.Enemy) {
      atk = _getEnemyAtk(act);
    }
    // 防御力
    var def = 0;
    if(target.group == BtlGroup.Enemy) {
      def = _getEnemyDef(target);
    }

    // 威力
    var power = str + (atk * 0.4) + BASE_ATK;

    // 力係数 (基礎体力の差)
    var str_rate = Math.pow(1.02, str - vit);

    // 威力係数 (装備アイテムの差)
    var power_rate = Math.pow(1.015, atk - def);

    //    trace('power: ${power} str_rate:${str_rate} pow_rate:${power_rate}');

    // ダメージ量を計算
    var val:Float = (power * str_rate * power_rate);

    return _clamp(val);
  }

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

        // 力
        var str = act.str;
        // 耐久力
        var vit = target.vit;
        // 攻撃力
        var atk = SkillUtil.getParam(skillID, "pow") * 0.2;
        // 防御力
        var def = 0;
        if(target.group == BtlGroup.Enemy) {
          def = _getEnemyDef(target);
        }

        // 威力
        //var power = str + (atk * 0.4) + BASE_ATK;
        var power = str + atk + BASE_ATK;

        // 力係数 (基礎体力の差)
        var str_rate = Math.pow(1.02, str - vit);

        // 威力係数 (装備アイテムの差)
        var power_rate = Math.pow(1.015, atk - def);

//        trace('power: ${power} str_rate:${str_rate} pow_rate:${power_rate}');

        // ダメージ量を計算
        val = (power * str_rate * power_rate);
      default:
        throw "未実装のスキル種別: " + type;
    }

    return _clamp(val);
  }
}
