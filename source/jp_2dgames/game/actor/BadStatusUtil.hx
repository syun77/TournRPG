package jp_2dgames.game.actor;

enum BadStatus {
  None;      // 何もなし
  Dead;      // 死亡
  Poison;    // 毒
  Confusion; // 混乱
  Closed;    // 封印
  Paralyze;  // 麻痺
  Sleep;     // 眠り
  Blind;     // 盲目
  Curse;     // 呪い
  Weak;      // 衰弱
}

/**
 * バッドステータスユーティリティ
 **/
class BadStatusUtil {
  public static function toString(s:BadStatus):String {
    return '${s}';
  }
  public static function fromString(str:String):BadStatus {
    switch(str) {
      case '${BadStatus.None}': return BadStatus.None;
      case '${BadStatus.Dead}': return BadStatus.Dead;
      case '${BadStatus.Poison}': return BadStatus.Poison;
      case '${BadStatus.Confusion}': return BadStatus.Confusion;
      case '${BadStatus.Closed}': return BadStatus.Closed;
      case '${BadStatus.Paralyze}': return BadStatus.Paralyze;
      case '${BadStatus.Sleep}': return BadStatus.Sleep;
      case '${BadStatus.Blind}': return BadStatus.Blind;
      case '${BadStatus.Curse}': return BadStatus.Curse;
      case '${BadStatus.Weak}': return BadStatus.Weak;
      default:
        return BadStatus.None;
    }
  }
}
