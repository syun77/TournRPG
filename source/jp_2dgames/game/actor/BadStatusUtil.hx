package jp_2dgames.game.actor;

import jp_2dgames.game.skill.SkillAttr;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
enum BadStatus {
  None;      // 何もなし
  Dead;      // 死亡
  Poison;    // 毒
  Confusion; // 混乱
  Close;     // 封印
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

  /**
   * バッドステータスを文字列として取得する
   **/
  public static function toString(bst:BadStatus):String {
    return '${bst}';
  }

  /**
   * 文字列からenum値に変換する
   **/
  public static function fromString(str:String):BadStatus {
    switch(str) {
      case '${BadStatus.None}':      return BadStatus.None;
      case '${BadStatus.Dead}':      return BadStatus.Dead;
      case '${BadStatus.Poison}':    return BadStatus.Poison;
      case '${BadStatus.Confusion}': return BadStatus.Confusion;
      case '${BadStatus.Close}':     return BadStatus.Close;
      case '${BadStatus.Paralyze}':  return BadStatus.Paralyze;
      case '${BadStatus.Sleep}':     return BadStatus.Sleep;
      case '${BadStatus.Blind}':     return BadStatus.Blind;
      case '${BadStatus.Curse}':     return BadStatus.Curse;
      case '${BadStatus.Weak}':      return BadStatus.Weak;
      default:
        return BadStatus.None;
    }
  }

  /**
   * バッドステータスが付着するかどうか
   **/
  public static function isAdhere(from:BadStatus, to:BadStatus):Bool {
    var a = _getPriority(from);
    var b = _getPriority(to);
    if(b > a) {
      // 新しいバステの方が優先順位が高い
      return true;
    }

    // 付着しない
    return false;
  }

  /**
   * バッドステータスの優先順位を取得する
   * @param bst バッドステータス
   * @return 優先順位。大きいほど優先順位が高い
   **/
  private static function _getPriority(bst:BadStatus):Int {
    switch(bst) {
      case BadStatus.Dead:      return 100;
      case BadStatus.Curse:     return 90;
      case BadStatus.Poison:    return 80;
      case BadStatus.Paralyze:  return 70;
      case BadStatus.Confusion: return 60;
      case BadStatus.Weak:      return 50;
      case BadStatus.Close:     return 30;
      case BadStatus.Sleep:     return 20;
      case BadStatus.Blind:     return 10;
      case BadStatus.None:      return 0;
    }
  }

  /**
   * バッドステータスメッセージの表示
   **/
  public static function pushMessage(badstatus:BadStatus, name:String):Void {
    var func = function(bst:BadStatus) {
      switch(bst) {
        case BadStatus.Dead:      return 0;
        case BadStatus.Curse:     return Msg.BST_CURSE;
        case BadStatus.Poison:    return Msg.BST_POISON;
        case BadStatus.Paralyze:  return Msg.BST_PARALYZE;
        case BadStatus.Confusion: return Msg.BST_CONFUSION;
        case BadStatus.Weak:      return Msg.BST_WEAK;
        case BadStatus.Close:     return Msg.BST_CLOSE;
        case BadStatus.Sleep:     return Msg.BST_SLEEP;
        case BadStatus.Blind:     return Msg.BST_BLIND;
        case BadStatus.None:      return 0;
      }
    }
    var msgID = func(badstatus);
    if(msgID != 0) {
      Message.push2(msgID, [name]);
    }
  }

  /**
   * スキル属性をバッドステータスに変換する
   **/
  public static function fromSkillAttribute(attr:SkillAttr):BadStatus {
    switch(attr) {
      case SkillAttr.Poision:   return BadStatus.Poison;
      case SkillAttr.Confusion: return BadStatus.Confusion;
      case SkillAttr.Close:     return BadStatus.Close;
      case SkillAttr.Paralyze:  return BadStatus.Paralyze;
      case SkillAttr.Sleep:     return BadStatus.Sleep;
      case SkillAttr.Blind:     return BadStatus.Blind;
      case SkillAttr.Curse:     return BadStatus.Curse;
      case SkillAttr.Weak:      return BadStatus.Weak;
      default:
        // 特になし
        return BadStatus.None;
    }
  }

  /**
   * 次のバステを取得する (デバッグ用）
   **/
  public static function next(bst:BadStatus):BadStatus {
    var tbl = [
      BadStatus.Dead      => BadStatus.None,
      BadStatus.Curse     => BadStatus.Dead,
      BadStatus.Poison    => BadStatus.Curse,
      BadStatus.Paralyze  => BadStatus.Poison,
      BadStatus.Confusion => BadStatus.Paralyze,
      BadStatus.Weak      => BadStatus.Confusion,
      BadStatus.Close     => BadStatus.Weak,
      BadStatus.Sleep     => BadStatus.Close,
      BadStatus.Blind     => BadStatus.Sleep,
      BadStatus.None      => BadStatus.Blind
    ];

    return tbl[bst];
  }

  /**
   * 前のバステを取得する（デバッグ用）
   **/
  public static function prev(bst:BadStatus):BadStatus {
    var tbl = [
      BadStatus.Dead      => BadStatus.Curse,
      BadStatus.Curse     => BadStatus.Poison,
      BadStatus.Poison    => BadStatus.Paralyze,
      BadStatus.Paralyze  => BadStatus.Confusion,
      BadStatus.Confusion => BadStatus.Weak,
      BadStatus.Weak      => BadStatus.Close,
      BadStatus.Close     => BadStatus.Sleep,
      BadStatus.Sleep     => BadStatus.Blind,
      BadStatus.Blind     => BadStatus.None,
      BadStatus.None      => BadStatus.Dead
    ];

    return tbl[bst];
  }

  /**
   * Actorが行動可能かどうか
   * @return 行動可能であればtrue
   **/
  public static function isActiveActor(actor:Actor):Bool {
    switch(actor.badstatus) {
      case BadStatus.Dead, BadStatus.Sleep:
        // 行動不可
        return false;

      default:
        // 行動可能
        return true;
    }
  }
}
