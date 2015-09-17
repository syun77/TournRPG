package jp_2dgames.game.btl.logic;
import jp_2dgames.game.skill.SkillUtil;
import flixel.util.FlxRandom;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.TempActorMgr;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.btl.logic.BtlLogicData;
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
        return _createSkill(skillID, actor, range, targetID);

      case BtlCmd.Item(item, range, targetID):
        // アイテム演出の作成
        return _createItem(item, actor, range, targetID);

      case BtlCmd.Escape:
        // 逃走演出の作成
        return _createEscape(actor);

      case BtlCmd.Dead, BtlCmd.BtlEnd, BtlCmd.None:
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
    var target = TempActorMgr.search(targetID);
    // ダメージ計算
    var val = Calc.damage(actor, target);
    if(val > 0) {
      // HPダメージ
      eft.vals.push(BtlLogicVal.HpDamage(val));
      // ダメージを与えておく
      target.damage(val, false);
    }
    else {
      // 回避された
      eft.vals.push(BtlLogicVal.ChanceRoll(false));
    }

    return eft;
  }

  /**
   * スキルを使う
   **/
  private static function _createSkill(skillID:Int, actor:Actor, range:BtlRange, targetID:Int):BtlLogicData {
    // TODO: 未実装
    var cmd = BtlCmd.Skill(skillID, range, targetID);
    var eft = new BtlLogicData(actor.ID, actor.group, cmd);
    eft.setTarget(range, targetID);

    // 対象を取得
    var target = TempActorMgr.search(targetID);

    // 攻撃回数を取得
    var min = SkillUtil.getParam(skillID, "min");
    var max = SkillUtil.getParam(skillID, "max");
    var cnt = FlxRandom.intRanged(min, max);

    // ダメージ計算
    // TODO: スキルダメージ計算式を作る
    for(i in 0...cnt) {
      var val = Calc.damage(actor, target);
      // HPダメージ
      eft.vals.push(BtlLogicVal.HpDamage(val));

      // ダメージを与える
      target.damage(val, false);
    }

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
    // TODO: 逃走確率チェック
    var bSuccess:Bool = true;
    var eft = new BtlLogicData(actor.ID, actor.group, BtlCmd.Escape(bSuccess));
    return eft;
  }

  /**
   * 死亡演出
   **/
  public static function createDead(actor:Actor):BtlLogicData {
    return new BtlLogicData(actor.ID, BtlGroup.Both, BtlCmd.Dead);
  }

  /**
   * バトル終了
   **/
  public static function createBtlEnd(bWin:Bool):BtlLogicData {
    return new BtlLogicData(0, BtlGroup.Both, BtlCmd.BtlEnd(bWin));
  }
}
