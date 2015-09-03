package jp_2dgames.game;

/**
 * 計算式
 **/
import flixel.util.FlxRandom;
class Calc {

  // 最大ダメージ
  static inline var MAX_DAMAGE:Int = 9999;

  // 基本攻撃力
  static inline var BASE_ATK:Int = 5;

  // ダメージのランダム補正係数
  static inline var DAMAGE_RATIO = 0.125;

  /**
   * ダメージ計算式
   **/
  public static function damage(act:Actor, target:Actor):Int {
    // 力
    var str = act.str;
    // 耐久力
    var vit = target.vit;
    // 攻撃力
    var atk = 0;
    // 防御力
    var def = 0;

    // 威力
    var power = str + (atk * 0.5) + BASE_ATK;
    // 防具でダメージ軽減
    power -= (def * 0.7);

    // 力係数 (基礎体力の差)
    var str_rate = Math.pow(1.02, str - vit);

    // 威力係数 (装備アイテムの差)
    var power_rate = Math.pow(1.015, atk - def);

    //    trace('power: ${power} str_rate:${str_rate} pow_rate:${power_rate}');

    // ダメージ量を計算
    var val = (power * str_rate * power_rate);
    if(val <= 0) {
      // 0ダメージはランダムで1〜3ダメージ
      val = FlxRandom.intRanged(1, 3);
    }
    else {
      // ランダムで変動
      var d = val * FlxRandom.floatRanged(-DAMAGE_RATIO, DAMAGE_RATIO);
      if(Math.abs(d) < 3) {
        // 3より小さい場合は+1〜3する
        val += FlxRandom.intRanged(1, 3);
      }
      else {
        val += d;
        if(val > MAX_DAMAGE) {
          // 最大ダメージ量を超えないようにする
          val = MAX_DAMAGE;
        }
      }
    }

    return Math.ceil(val);

  }
}
