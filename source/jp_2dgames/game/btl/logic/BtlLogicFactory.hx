package jp_2dgames.game.btl.logic;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.btl.logic.BtlLogicData;
import flixel.FlxG;
import jp_2dgames.game.skill.SkillType;
import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.skill.SkillUtil;
import flixel.util.FlxRandom;
import jp_2dgames.game.actor.TempActorMgr;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.btl.types.BtlCmd;
import jp_2dgames.game.actor.Actor;

/**
 * 演出を生成するクラス
 **/
class BtlLogicFactory {

  /**
   * 演出の生成
   **/
  public static function create(actor:Actor):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    switch(actor.cmd) {
      case BtlCmd.Attack(range, targetID):
        // 攻撃演出の作成
        // 開始
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.BeginAttack));

        // 攻撃
        var eft = _createAttack(actor, range, targetID);
        ret.add(eft);

        // 終了
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.EndAction));

      case BtlCmd.Skill(skillID, range, targetID):
        // スキル演出の作成
        // 開始
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.BeginSkill(skillID)));

        // 発動
        var efts = _createSkill(skillID, actor, range, targetID);
        for(eft in efts) {
          ret.add(eft);
        }

        // 終了
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.EndAction));

      case BtlCmd.Item(item, range, targetID):
        // アイテム演出の作成
        // 開始
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.BeginItem(item)));

        // 使う
        var eft = _createItem(item, actor, range, targetID);
        ret.add(eft);

        // 終了
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.EndAction));

      case BtlCmd.Escape:
        // 逃走演出の作成
        var eft = _createEscape(actor);
        ret.add(eft);

      case BtlCmd.None:
        // 通常ありえない
        return null;
    }

    return ret;
  }

  /**
   * 通常攻撃
   **/
  private static function _createAttack(actor:Actor, range:BtlRange, targetID:Int):BtlLogicData {

    // 対象を取得
    var target = TempActorMgr.search(targetID);
    // ダメージ計算
    var val = Calc.damage(actor, target);
    var eft = _createDamage(actor, target, val, false);

    return eft;
  }

  /**
   * スキルを使う
   **/
  private static function _createSkill(skillID:Int, actor:Actor, range:BtlRange, targetID:Int):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    // スキル種別を取得
    var type = SkillUtil.toType(skillID);

    // 対象を取得
    var target = TempActorMgr.search(targetID);

    switch(type) {
      case SkillType.AtkPhyscal, SkillType.AtkMagical:
        // 攻撃回数を取得
        var min = SkillUtil.getParam(skillID, "min");
        var max = SkillUtil.getParam(skillID, "max");
        var cnt = FlxRandom.intRanged(min, max);

        // ダメージ計算
        if(cnt > 1) {
          // 連続攻撃
          for(i in 0...cnt) {
            var val = Calc.damageSkill(skillID, actor, target);
            var eft = _createDamage(actor, target, val, true);
            eft.bAttackEnd = false;
            if(i == cnt-1) {
              // 攻撃終了
              eft.bAttackEnd = true;
            }
            // 演出データを追加
            ret.add(eft);
          }
        }
        else {
          // 1回攻撃
          switch(range) {
            case BtlRange.One:
              // 単体
              var val = Calc.damageSkill(skillID, actor, target);
              var eft = _createDamage(actor, target, val);
              ret.add(eft);

            case BtlRange.Group:
              // グループ
              TempActorMgr.forEachAliveGroup(target.group, function(act:Actor) {
                var val = Calc.damageSkill(skillID, actor, act);
                var eft = _createDamage(actor, act, val);
                ret.add(eft);
              });

            default:
              // TODO: 未実装
              throw 'Not implements range(${range})';
          }
        }
      case SkillType.AtkBadstatus:
        // バステ攻撃
        switch(range) {
          case BtlRange.One:
            // 単体
            var eft = _createBadstatus(actor, skillID, actor.group, target);
            // 演出データを追加
            ret.add(eft);

          case BtlRange.Group:
            // グループ
            TempActorMgr.forEachAliveGroup(target.group, function(act:Actor) {
              var eft = _createBadstatus(actor, skillID, actor.group, act);
              // 演出データを追加
              ret.add(eft);
            });

          default:
            // TODO:
            throw 'Not implements range(${range})';
        }
      default:
        FlxG.log.warn('Invalid SkillType "${SkillType}"');
    }

    return ret;
  }

  /**
   * ダメージ演出生成
   **/
  private static function _createDamage(actor:Actor, target:Actor, val:Int, bSeq:Bool=false):BtlLogicData {

    var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
    eft.setTarget(target.ID);

    if(val > 0) {
      // HPダメージ
      eft.type = BtlLogic.HpDamage(val, bSeq);
      // ダメージを与える
      target.damage(val);
    }
    else {
      // 回避された
      eft.type = BtlLogic.ChanceRoll(false);
    }

    return eft;
  }

  private static function _createBadstatus(actor:Actor, skillID:Int, group:BtlGroup, target:Actor):BtlLogicData {
    var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
    eft.setTarget(target.ID);
    var attr = SkillUtil.toAttribute(skillID);
    var bst  = BadStatusUtil.fromSkillAttribute(attr);
    eft.type = BtlLogic.Badstatus(bst);

    // バステ付着
    target.adhereBadStatus(bst);

    return eft;
  }

  /**
   * アイテムを使う
   **/
  private static function _createItem(item:ItemData, actor:Actor, range:BtlRange, targetID:Int):BtlLogicData {

    // TODO: アイテム効果反映
    var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.Item(item));
    return eft;
  }

  /**
   * 逃走をする
   **/
  private static function _createEscape(actor:Actor):BtlLogicData {
    // TODO: 逃走確率チェック
    var bSuccess:Bool = true;
    var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.Escape(bSuccess));
    return eft;
  }

  /**
   * 死亡演出
   **/
  public static function createDead(actor:Actor):BtlLogicData {
    return new BtlLogicData(actor.ID, BtlGroup.Both, BtlLogic.Dead);
  }

  /**
   * バトル終了
   **/
  public static function createBtlEnd(bWin:Bool):BtlLogicData {
    return new BtlLogicData(0, BtlGroup.Both, BtlLogic.BtlEnd(bWin));
  }

  /**
   * ターン終了演出の生成
   **/
  public static function createTurnEnd(actor:Actor):BtlLogicData {

    switch(actor.badstatus) {
      case BadStatus.None:
        // 何もしない
        return null;

      case BadStatus.Poison:
        // TODO: 10ダメージ固定
        var val = 10;
        var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
        // 自分自身が対象
        eft.setTarget(actor.ID);
        eft.type = BtlLogic.HpDamage(val, false);
        actor.damage(val);

        return eft;

      default:
        // 何もしない
        return null;
    }
  }
}
