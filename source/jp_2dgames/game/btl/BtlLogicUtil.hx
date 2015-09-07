package jp_2dgames.game.btl;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.btl.BtlLogicData;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.btl.BtlCmdUtil;
import jp_2dgames.game.actor.Actor;

class BtlLogicUtil {
  public static function create(actor:Actor):BtlLogicData {
    switch(actor.cmd) {
      case BtlCmd.Attack(target, targetID):
        // 攻撃演出の作成
        return _createAttack(actor, target, targetID);
      case BtlCmd.Skill(skillID, target, targetID):
        return _createSkill(skillID, actor, target);
      case BtlCmd.Item(item, target, targetID):
        return _createItem(item, actor, target, targetID);
      case BtlCmd.Escape:
        return _createEscape(actor);
      case BtlCmd.None:
        return null;
    }
  }

  /**
   * 通常攻撃
   **/
  private static function _createAttack(actor:Actor, range:BtlRange, targetID:Int):BtlLogicData {
    // TODO: 相手グループをランダム攻撃
    var group = BtlGroupUtil.getAgaint(actor.group);
    var target = ActorMgr.random(group);

    var eft = new BtlLogicData(actor.ID, actor.group, BtlCmd.Attack(range, target.ID));
    eft.setTarget(range, target.ID);

    // ダメージ計算
    var val = Calc.damage(actor, target);
    // HPダメージ
    eft.val = BtlLogicVal.HpDamage(val);

    return eft;
  }

  /**
   * スキルを使う
   **/
  private static function _createSkill(skillID:Int, actor:Actor, target:BtlRange):BtlLogicData {
    // TODO: 未実装
    var cmd = BtlCmd.Skill(skillID, target, 0);
    var eft = new BtlLogicData(actor.ID, actor.group, cmd);
    return eft;
  }

  /**
   * アイテムを使う
   **/
  private static function _createItem(item:ItemData, actor:Actor, target:BtlRange, targetID:Int):BtlLogicData {
    var cmd = BtlCmd.Item(item, target, targetID);
    var eft = new BtlLogicData(actor.ID, actor.group, cmd);
    return eft;
  }

  /**
   * 逃走をする
   **/
  private static function _createEscape(actor:Actor):BtlLogicData {
    // TODO: 未実装
    var eft = new BtlLogicData(actor.ID, actor.group, BtlCmd.Escape);
    return eft;
  }

}
