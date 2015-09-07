package jp_2dgames.game.btl.logic;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.btl.logic.BtlLogicData;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.btl.types.BtlCmd;
import jp_2dgames.game.actor.Actor;

/**
 * 演出を生成するクラス
 **/
class BtlLogicUtil {

  /**
   * 演出の生成
   **/
  public static function create(actor:Actor):BtlLogicData {
    switch(actor.cmd) {
      case BtlCmd.Attack(range, targetID):
        // 攻撃演出の作成
        return _createAttack(actor, range, targetID);

      case BtlCmd.Skill(skillID, range, targetID):
        // スキル演出の作成
        return _createSkill(skillID, actor, range);

      case BtlCmd.Item(item, range, targetID):
        // アイテム演出の作成
        return _createItem(item, actor, range, targetID);

      case BtlCmd.Escape:
        // 逃走演出の作成
        return _createEscape(actor);

      case BtlCmd.None:
        // 通常ありえない
        return null;
    }
  }

  /**
   * 通常攻撃
   **/
  private static function _createAttack(actor:Actor, range:BtlRange, targetID:Int):BtlLogicData {
    var eft = new BtlLogicData(actor.ID, actor.group, BtlCmd.Attack(range, targetID));
    eft.setTarget(range, targetID);

    // 対象を取得
    var target = ActorMgr.search(targetID);
    // ダメージ計算
    var val = Calc.damage(actor, target);
    // HPダメージ
    eft.val = BtlLogicVal.HpDamage(val);

    return eft;
  }

  /**
   * スキルを使う
   **/
  private static function _createSkill(skillID:Int, actor:Actor, range:BtlRange):BtlLogicData {
    // TODO: 未実装
    var cmd = BtlCmd.Skill(skillID, range, 0);
    var eft = new BtlLogicData(actor.ID, actor.group, cmd);
    return eft;
  }

  /**
   * アイテムを使う
   **/
  private static function _createItem(item:ItemData, actor:Actor, range:BtlRange, targetID:Int):BtlLogicData {
    var cmd = BtlCmd.Item(item, range, targetID);
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
