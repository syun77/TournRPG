package jp_2dgames.game.btl.logic;
import jp_2dgames.game.item.ItemUtil;
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
        // コストチェック
        var eftCost = _createSkillCost(skillID, actor);
        if(eftCost != null) {
          ret.add(eftCost);
        }

        // 開始
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.BeginSkill(skillID)));

        if(eftCost != null) {
          // 発動
          var efts = _createSkill(skillID, actor, range, targetID);
          for(eft in efts) {
            ret.add(eft);
          }
        }
        else {
          // 発動できない
          ret.add(_createSkillCostNotEnough(skillID, actor));
        }

        // 終了
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.EndAction));

      case BtlCmd.Item(item, range, targetID):
        // アイテム演出の作成
        // 開始
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.BeginItem(item)));

        // 使う
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.UseItem(item)));

        // アイテム効果
        var eft = _createItem(item, actor, range, targetID);
        if(eft == null) {
          throw '未実装のアイテム ID(${item.id})';
        }
        ret.add(eft);

        // 終了
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.EndAction));

      case BtlCmd.Escape:
        // 逃走演出の作成
        // 開始
        ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.Message2(Msg.ESCAPE, [actor.name])));

        // 実行
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
   * スキルコスト消費
   **/
  private static function _createSkillCost(skillID:Int, actor:Actor):BtlLogicData {
    var hp = SkillUtil.getCostHp(skillID);
    if(hp > 0) {
      // HP消費
      if(hp >= actor.hp) {
        // 足りない
        return null;
      }

      // 足りている
      var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.SkillCost(hp, 0));
      // HPを減らす
      actor.damage(hp);

      return eft;
    }
    else {
      // MP消費
      var mp = SkillUtil.getCostMp(skillID);
      if(mp > actor.mp) {
        // 足りない
        return null;
      }

      // 足りている
      var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.SkillCost(0, mp));
      // MPを減らす
      actor.damage(mp);

      return eft;
    }
  }

  /**
   * スキルコスト足りないメッセージ
   **/
  private static function _createSkillCostNotEnough(skillID:Int, actor:Actor):BtlLogicData {
    var hp = SkillUtil.getCostHp(skillID);
    if(hp > 0) {
      // HP不足
      return new BtlLogicData(actor.ID, actor.group, BtlLogic.Message(Msg.NOT_ENOUGH_HP));
    }
    else {
      // MP不足
      return new BtlLogicData(actor.ID, actor.group, BtlLogic.Message(Msg.NOT_ENOUGH_TP));
    }
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
            eft.bWaitQuick = true;
            if(i == cnt-1) {
              // 攻撃終了
              eft.bWaitQuick = false;
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

  /**
   * バットステータス付着
   **/
  private static function _createBadstatus(actor:Actor, skillID:Int, group:BtlGroup, target:Actor):BtlLogicData {
    var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
    eft.setTarget(target.ID);
    var attr = SkillUtil.toAttribute(skillID);
    var bst  = BadStatusUtil.fromSkillAttribute(attr);
    eft.type = BtlLogic.Badstatus(bst);
    eft.bWaitQuick = true;

    // バステ付着
    target.adhereBadStatus(bst);

    return eft;
  }

  /**
   * アイテムを使う
   **/
  private static function _createItem(item:ItemData, actor:Actor, range:BtlRange, targetID:Int):BtlLogicData {

    var hp = ItemUtil.getParam(item.id, "hp");
    if(hp > 0) {
      // HP回復
      var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.HpRecover(hp));
      eft.setTarget(actor.ID);

      // 回復しておく
      actor.recoverHp(hp);

      return eft;
    }
    return null;
  }

  /**
   * 逃走をする
   **/
  private static function _createEscape(actor:Actor):BtlLogicData {

    // 相手からAGI値の一番高いActorを選出
    var enemyAGI:Int = 0;
    TempActorMgr.forEachAliveGroup(BtlGroupUtil.getAgaint(actor.group), function(act:Actor) {
      if(enemyAGI < act.agi) {
        enemyAGI = act.agi;
      }
    });

    if(Calc.isEscape(actor.agi, enemyAGI)) {
      // 逃走成功
      return new BtlLogicData(actor.ID, actor.group, BtlLogic.Escape);
    }
    else {
      // 失敗
      return new BtlLogicData(actor.ID, actor.group, BtlLogic.Message(Msg.ESCAPE_FAILED));
    }

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
  public static function createTurnEnd(actor:Actor):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    // 毒ダメージ
    if(actor.badstatus == BadStatus.Poison) {
      // TODO: 10ダメージ固定
      var val = 10;
      var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
      // 自分自身が対象
      eft.setTarget(actor.ID);
      eft.type = BtlLogic.HpDamage(val, false);
      eft.bWaitQuick = true;
      actor.damage(val);
      ret.add(eft);
    }

    // 自然回復チェック
    if(Calc.cureBadstatus(actor)) {
      // バステ回復
      actor.cureBadStatus();
    }

  return ret;
  }
}
