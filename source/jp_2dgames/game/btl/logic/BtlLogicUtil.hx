package jp_2dgames.game.btl.logic;
import jp_2dgames.game.btl.logic.BtlLogicData;
import flixel.FlxG;
import jp_2dgames.game.skill.SkillType;
import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.skill.SkillUtil;
import flixel.util.FlxRandom;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.TempActorMgr;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.btl.types.BtlCmd;
import jp_2dgames.game.actor.Actor;

/**
 * 演出を生成するクラス
 **/
class BtlLogicUtil {

  /**
   * 演出の生成
   **/
  public static function create(actor:Actor):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    switch(actor.cmd) {
      case BtlCmd.Attack(range, targetID):
        // 攻撃演出の作成
        var eft = _createAttack(actor, range, targetID);
        ret.add(eft);

      case BtlCmd.Skill(skillID, range, targetID):
        // スキル演出の作成
        var efts = _createSkill(skillID, actor, range, targetID);
        for(eft in efts) {
          ret.add(eft);
        }

      case BtlCmd.Item(item, range, targetID):
        // アイテム演出の作成
        var eft = _createItem(item, actor, range, targetID);
        ret.add(eft);

      case BtlCmd.Escape:
        // 逃走演出の作成
        var eft = _createEscape(actor);
        ret.add(eft);

      case BtlCmd.Dead, BtlCmd.BtlEnd, BtlCmd.TurnEnd, BtlCmd.Sequence, BtlCmd.None:
        // 通常ありえない
        return null;
    }

    return ret;
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
      target.damage(val);
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
  private static function _createSkill(skillID:Int, actor:Actor, range:BtlRange, targetID:Int):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    var cmd = BtlCmd.Skill(skillID, range, targetID);
    var eft = new BtlLogicData(actor.ID, actor.group, cmd);
    eft.setTarget(range, targetID);

    // スキル種別を取得
    var type = SkillUtil.toType(skillID);

    // 対象を取得
    var target = TempActorMgr.search(targetID);

    // 攻撃回数を取得
    var min = SkillUtil.getParam(skillID, "min");
    var max = SkillUtil.getParam(skillID, "max");
    var cnt = FlxRandom.intRanged(min, max);

    switch(type) {
      case SkillType.AtkPhyscal, SkillType.AtkMagical:
        // ダメージ計算
        if(cnt > 1) {
          // 連続攻撃
          for(i in 0...cnt) {
            var val = Calc.damageSkill(skillID, actor, target);
            if(val > 0) {
              // HPダメージ
              eft.vals.push(BtlLogicVal.HpDamage(val));
              // ダメージを与える
              target.damage(val);
            }
            else {
              // 回避された
              eft.vals.push(BtlLogicVal.ChanceRoll(false));
            }
          }

          // 演出データを追加
          ret.add(eft);
        }
        else {
          // 1回攻撃
          switch(range) {
            case BtlRange.One:
              // 単体
              var val = Calc.damageSkill(skillID, actor, target);
              _damageTarget(eft, target, val);

            case BtlRange.Group:
              // グループ
              TempActorMgr.forEachAliveGroup(target.group, function(act:Actor) {
                var val = Calc.damageSkill(skillID, actor, act);
                if(eft != null) {
                  // 初回のダメージ
                  _damageTarget(eft, act, val);
                  ret.add(eft);
                  eft = null;
                }
                else {
                  // 2回目以降のダメージ
                  var cmd = BtlCmd.Sequence;
                  var eft2 = new BtlLogicData(act.ID, act.group, cmd);
                  eft2.setTarget(range, targetID);
                  _damageTarget(eft, act, val);
                  ret.add(eft2);
                }
              });

            default:
              // TODO: 未実装
              throw "Not implements.";
          }

          // 演出データを追加
          ret.add(eft);
        }
      case SkillType.AtkBadstatus:
        // バステ攻撃
        switch(range) {
          case BtlRange.One:
            // 単体
            var attr = SkillUtil.toAttribute(skillID);
            var bst  = BadStatusUtil.fromSkillAttribute(attr);
            eft.vals.push(BtlLogicVal.Badstatus(bst));

            // バステ付着
            target.adhereBadStatus(bst);

            // 演出データを追加
            ret.add(eft);

          case BtlRange.Group:
            // グループ
            TempActorMgr.forEachAliveGroup(target.group, function(act:Actor) {
              if(eft != null) {
                // 初回
                var attr = SkillUtil.toAttribute(skillID);
                var bst  = BadStatusUtil.fromSkillAttribute(attr);
                eft.vals.push(BtlLogicVal.Badstatus(bst));
                eft.setTarget(range, act.ID);

                // バステ付着
                act.adhereBadStatus(bst);
                ret.add(eft);
                eft = null;
              }
              else {
                // 2回目以降
                var cmd = BtlCmd.Sequence;
                var eft2 = new BtlLogicData(act.ID, act.group, cmd);
                eft2.setTarget(range, act.ID);
                var attr = SkillUtil.toAttribute(skillID);
                var bst  = BadStatusUtil.fromSkillAttribute(attr);
                eft2.vals.push(BtlLogicVal.Badstatus(bst));

                // バステ付着
                target.adhereBadStatus(bst);
                ret.add(eft2);
              }
            });

          default:
            // TODO:
        }
      default:
        FlxG.log.warn('Invalid SkillType "${SkillType}"');
    }

    return ret;
  }

  private static function _damageTarget(eft:BtlLogicData, target:Actor, val:Int):Void {
    if(val > 0) {
      // HPダメージ
      eft.vals.push(BtlLogicVal.HpDamage(val));
      // ダメージを与える
      target.damage(val);
    }
    else {
      // 回避された
      eft.vals.push(BtlLogicVal.ChanceRoll(false));
    }
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

  /**
   * ターン終了演出の生成
   **/
  public static function createTurnEnd(actor:Actor):BtlLogicData {

    var eft = new BtlLogicData(actor.ID, actor.group, BtlCmd.TurnEnd);
    eft.range = BtlRange.Self;

    switch(actor.badstatus) {
      case BadStatus.None:
        // 何もしない
        eft = null;

      case BadStatus.Poison:
        // TODO: 10ダメージ固定
        var val = BtlLogicVal.HpDamage(10);
        eft.vals.push(val);
        actor.damage(10);

      default:
        // 何もしない
        eft = null;
    }

    return eft;
  }
}
