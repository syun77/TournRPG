package jp_2dgames.game.btl.logic;
import jp_2dgames.game.field.FieldEffectUtil.FieldEffect;
import haxe.macro.Expr.Field;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.skill.SkillSlot;
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
        {
          var type = BtlLogic.BeginEffect(BtlLogicBegin.Attack);
          var d = new BtlLogicData(actor.ID, actor.group, type);
          d.setTarget(targetID);
          ret.add(d);
        }
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
    // 命中判定
    if(Calc.checkHit(actor, target) == false) {
      // 外れ
      var eft = _createDamage(actor, target, Calc.MISS_DAMAGE, false);
      return eft;
    }
    else {
      // ダメージ計算
      var val = Calc.damage(actor, target);
      var eft = _createDamage(actor, target, val, false);
      return eft;
    }
  }

  /**
   * スキルコスト消費
   **/
  private static function _createSkillCost(skillID:Int, actor:Actor):BtlLogicData {
    var hp = SkillUtil.getCostHp(skillID, actor);
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
      var mp = SkillUtil.getCostMp(skillID, actor);
      if(mp > actor.mp) {
        // 足りない
        return null;
      }

      // 足りている
      var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.SkillCost(0, mp));
      // MPを減らす
      actor.damageMp(mp);

      return eft;
    }
  }

  /**
   * スキルコスト足りないメッセージ
   **/
  private static function _createSkillCostNotEnough(skillID:Int, actor:Actor):BtlLogicData {
    var hp = SkillUtil.getCostHp(skillID, actor);
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
        // 物理・魔法
        _createSkillPhysicsAndMagic(actor, target, range, skillID, ret);

      case SkillType.AtkBadstatus:
        // バステ攻撃
        switch(range) {
          case BtlRange.One:
            // 単体
            var eft = _createBadstatus(actor, skillID, target, true);
            // 演出データを追加
            ret.add(eft);

          case BtlRange.Group:
            // グループ
            TempActorMgr.forEachAliveGroup(target.group, function(act:Actor) {
              var eft = _createBadstatus(actor, skillID, act, true);
              // 演出データを追加
              ret.add(eft);
            });

          default:
            // TODO:
            throw 'Not implements range(${range})';
        }

      case SkillType.Recover:
        // 回復
        switch(range) {
          case BtlRange.Self:
            // 自分自身
            ret.add(_createRecover(actor, skillID, actor));

          case BtlRange.One:
            // 単体
            ret.add(_createRecover(actor, skillID, target));

          case BtlRange.Group:
            // グループ
            TempActorMgr.forEachAliveGroup(target.group, function(act:Actor) {
              ret.add(_createRecover(actor, skillID, act));
            });

          default:
            // TODO:
            throw 'Not implements range(${range})';
        }

      case SkillType.Buff:
        // バフ
        switch(range) {
          case BtlRange.Self:
            // 自分自身
            var efts = _createBuff(actor, skillID, actor);
            for(eft in efts) { ret.add(eft); }

          case BtlRange.One:
            // 単体
            var efts = _createBuff(actor, skillID, target);
            for(eft in efts) { ret.add(eft); }

          case BtlRange.Group:
            // グループ
            TempActorMgr.forEachAliveGroup(target.group, function(act:Actor) {
              var efts = _createBuff(actor, skillID, act);
              for(eft in efts) { ret.add(eft); }
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
   * スキル演出　物理・魔法の生成
   **/
  private static function _createSkillPhysicsAndMagic(actor:Actor, target:Actor, range:BtlRange, skillID:Int, ret:List<BtlLogicData>):Void {

    // 攻撃回数を取得
    var min = SkillUtil.getParam(skillID, "min");
    var max = SkillUtil.getParam(skillID, "max");
    var cnt = FlxRandom.intRanged(min, max);

    // ダメージ演出作成関数
    var fnDamage = function(target2:Actor, idx:Int):Bool {

      // 命中判定
      var hit = SkillUtil.getBaseHit(skillID);
      if(Calc.checkHit(actor, target2, hit) == false) {
        // 外れた
        var eft = _createDamage(actor, target2, Calc.MISS_DAMAGE, true);
        ret.add(eft);
        return false;
      }

      // ダメージ処理
      var val = Calc.damageSkill(skillID, actor, target2);
      var eft = _createDamage(actor, target2, val, true);
      eft.bWaitQuick = true;
      if(idx == -1 || idx == cnt-1) {
        // 攻撃終了
        eft.bWaitQuick = false;
      }
      // 演出データを追加
      ret.add(eft);
      // 死亡チェック
      for(eft in checkDeadAndCreate()) {
        ret.add(eft);
      }
      if(target2.isDead()) {
        // 死亡
        return true;
      }
      else if(val > 0) {
        // 死亡していないのでバステチェック
        if(SkillUtil.getBadstatus(skillID) != BadStatus.None) {
          // 単体
          var eft = _createBadstatus(actor, skillID, target2, false);
          if(eft != null) {
            // 演出データを追加
            ret.add(eft);
          }
        }
      }

      return false;
    }

    // ダメージ計算
    if(cnt > 1) {
      // 連続攻撃
      for(i in 0...cnt) {
        if(fnDamage(target, i)) {
          // 死亡
          break;
        }
      }
    }
    else {
      // 1回攻撃
      switch(range) {
        case BtlRange.One:
          // 単体ダメージ
          fnDamage(target, -1);

        case BtlRange.Group:
          // グループ
          TempActorMgr.forEachAliveGroup(target.group, function(act:Actor) {
            fnDamage(act, -1);
          });

        default:
          // TODO: 未実装
          throw 'Not implements range(${range})';
      }
    }

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
  private static function _createBadstatus(actor:Actor, skillID:Int, target:Actor, bMissEft:Bool):BtlLogicData {

    var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
    eft.setTarget(target.ID);
    // 付着判定
    if(Calc.checkHitBadstatus(actor, target, skillID) == false) {
      // 失敗
      eft.type = BtlLogic.ChanceRoll(false);
      if(bMissEft == false) {
        // 失敗したら演出なし
        return null;
      }
      return eft;
    }

    var bst = SkillUtil.getBadstatus(skillID);
    // バステ威力値
    var v = SkillUtil.getBadstatusPower(skillID);
    var val = Calc.powerBadstatus(actor, target, bst, v);

    eft.type = BtlLogic.Badstatus(bst, val);
    eft.bWaitQuick = true;

    // バステ付着
    target.adhereBadStatus(bst, val);

    return eft;
  }

  /**
   * 回復
   **/
  private static function _createRecover(actor:Actor, skillID:Int, target:Actor):BtlLogicData {
    var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
    eft.setTarget(target.ID);
    var hp = SkillUtil.getParam(skillID, "rec");
    if(hp > 0) {
      var v = Calc.recoverHp(actor, hp);
      eft.type = BtlLogic.HpRecover(v);

      // HP回復
      target.recoverHp(v);
    }

    return eft;
  }

  /**
   * バフ
   **/
  private static function _createBuff(actor:Actor, skillID:Int, target:Actor):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    // 効果
    var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
    eft.setTarget(target.ID);
    eft.bWaitQuick = true;
    var atk = SkillUtil.getParam(skillID, "buff_atk");
    var def = SkillUtil.getParam(skillID, "buff_def");
    var spd = SkillUtil.getParam(skillID, "buff_spd");
    eft.type = BtlLogic.Buff(atk, def, spd);

    // バフ・デバフ
    target.addBuffAtk(atk);
    target.addBuffDef(def);
    target.addBuffSpd(spd);

    // 開始
    {
      var ave = (atk + def + spd) / 3;
      var begin = if(ave > 0) BtlLogicBegin.PowerUp else BtlLogicBegin.PowerDown;
      var type = BtlLogic.BeginEffect(begin);
      var d = new BtlLogicData(actor.ID, actor.group, type);
      d.setTarget(target.ID);
      ret.add(d);
    }
    ret.add(eft);

    if(atk > 0) {
      ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.Message2(Msg.BUFF_ATK_UP, [target.name])));
    }
    if(atk < 0) {
      ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.Message2(Msg.BUFF_ATK_DOWN, [target.name])));
    }
    if(def > 0) {
      ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.Message2(Msg.BUFF_DEF_UP, [target.name])));
    }
    if(def < 0) {
      ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.Message2(Msg.BUFF_DEF_DOWN, [target.name])));
    }
    if(spd > 0) {
      ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.Message2(Msg.BUFF_SPD_UP, [target.name])));
    }
    if(spd < 0) {
      ret.add(new BtlLogicData(actor.ID, actor.group, BtlLogic.Message2(Msg.BUFF_SPD_DOWN, [target.name])));
    }

    return ret;
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
   * 死亡チェック＋死亡演出作成
   **/
  public static function checkDeadAndCreate():List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    // 死亡チェック
    var idx = ActorMgr.MAX;
    while(idx > 0) {

      // 死亡している人を探す
      var actor = TempActorMgr.searchDead();
      if(actor == null) {
        // 死亡している人はいないのでおしまい
        break;
      }

      if(_checkAutoRevive(actor)) {
        // 自動復活できる
        var eftList = BtlLogicFactory.createAutoRevive(actor);
        for(eft in eftList) {
          ret.push(eft);
        }
      }
      else {
        // 復活できないので死亡
        var eft = BtlLogicFactory.createDead(actor);
        ret.push(eft);
        // そして墓場送り
        TempActorMgr.moveGrave(actor);
      }

      idx--;
    }

    return ret;
  }

  /**
   * 復活できるかどうか
   **/
  private static function _checkAutoRevive(actor:Actor):Bool {
    if(actor.group != BtlGroup.Player) {
      // 復活できない
      return false;
    }

    // 自動復活済みかどうかをチェック
    if(actor.param.bAutoRevive) {
      // すでに復活したので復活できない
      return false;
    }

    // 復活スキルをチェック
    var skillID = SkillSlot.getReviveSkillID();
    if(skillID == 0) {
      // 復活スキルを持っていない
      return false;
    }

    // 復活できる
    return true;
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
  public static function createBtlEnd(actor:Actor, bWin:Bool):BtlLogicData {
    var id:Int = 0;
    if(actor != null) {
      id = actor.ID;
    }
    return new BtlLogicData(id, BtlGroup.Both, BtlLogic.BtlEnd(bWin));
  }

  /**
   * ターン終了演出の生成
   **/
  public static function createTurnEnd(actor:Actor):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    // スキル効果
    _createTurnEndSkill(actor, ret);

    // バッドステータスの生成
    _createTurnEndBadstatus(actor, ret);

    if(actor.isDead()) {
      // 死んでいたら処理しない
      return ret;
    }

    // 地形効果発動
    _createTurnEndFieldEffect(actor, ret);

    return ret;
  }

  /**
   * ターン終了時のスキル効果
   **/
  private static function _createTurnEndSkill(actor:Actor, ret:List<BtlLogicData>):Void {
    if(actor.group == BtlGroup.Enemy) {
      // 敵には何も起こらない
      return;
    }

    // ターン終了時のHP回復値を取得
    var rec_hp = SkillSlot.getTurnEndRecoveryHp();
    if(rec_hp > 0) {
      var type = BtlLogic.HpRecover(rec_hp);
      var eft = new BtlLogicData(actor.ID, actor.group, type);
      // 自分自身が対象
      eft.setTarget(actor.ID);
      ret.add(eft);
      actor.recoverHp(rec_hp);
    }

    // ターン終了時のMP回復値を取得
    var rec_mp = SkillSlot.getTurnEndRecoveryMp();
    if(rec_mp > 0) {
      var type = BtlLogic.MpRecover(rec_mp);
      var eft = new BtlLogicData(actor.ID, actor.group, type);
      // 自分自身が対象
      eft.setTarget(actor.ID);
      ret.add(eft);
      actor.recoverMp(rec_hp);
    }
  }

  /**
   * ターン終了時のバッドステータス効果・回復
   **/
  private static function _createTurnEndBadstatus(actor:Actor, ret:List<BtlLogicData>):Void {
    // 毒ダメージ
    if(actor.badstatus == BadStatus.Poison) {
      var val = Calc.damagePoison(actor);
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
      var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
      // 自分自身が対象
      eft.setTarget(actor.ID);
      eft.type = BtlLogic.Badstatus(BadStatus.None, 0);
      ret.add(eft);
    }
  }

  /**
   * ターン終了時の地形効果
   **/
  private static function _createTurnEndFieldEffect(actor:Actor, ret:List<BtlLogicData>):Void {

    switch(BtlGlobal.getFieldEffect()) {
      case FieldEffect.None:
        // 何もなし
      case FieldEffect.Damage:
        // ターン経過でダメージ
        var val = Calc.damageFieldEffect(actor, BtlGlobal.getTurn());
        var type = BtlLogic.HpDamage(val, false);
        var eft = new BtlLogicData(actor.ID, actor.group, type);
        // 自分自身が対象
        eft.setTarget(actor.ID);
        eft.bWaitQuick = true;
        actor.damage(val);
        ret.add(eft);
      case FieldEffect.Poison:
        // 3ターンごとに毒発生
        if(BtlGlobal.getTurn()%3 != 1) {
          return;
        }
        // 5%ダメージ
        var val = Calc.damageFieldEffect(actor, BtlGlobal.getTurn());
        if(actor.adhereBadStatus(BadStatus.Poison, val)) {
          // 付着成功
          var type = BtlLogic.Badstatus(BadStatus.Poison, val);
          var eft = new BtlLogicData(actor.ID, actor.group, type);
          // 自分自身が対象
          eft.setTarget(actor.ID);
          eft.bWaitQuick = true;
          ret.add(eft);
        }
    }
  }

  /**
   * 行動不能演出の生成
   **/
  public static function createDeactive(actor:Actor):BtlLogicData {
    var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.None);
    switch(actor.badstatus) {
      case BadStatus.Sleep:
        eft.type = BtlLogic.Message2(Msg.SLEEPING, [actor.name]);

      case BadStatus.Close:
        eft.type = BtlLogic.Message2(Msg.CLOSING, [actor.name]);

      case BadStatus.Paralyze:
        eft.type = BtlLogic.Message2(Msg.PARALYZING, [actor.name]);

      default:
        throw 'この状態で行動不能になることはない ${actor.name}, ${actor.badstatus}';
    }

    return eft;
  }

  /**
   * 自動復活スキル演出の生成
   **/
  public static function createAutoRevive(actor:Actor):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    // 自動復活スキルのIDを取得する
    var skillID = SkillSlot.getReviveSkillID();
    if(skillID == 0) {
      return ret;
    }

    var rec_val = SkillUtil.getRevive(skillID);
    var rec_hp = Std.int(actor.hpmax * rec_val / 100);
    if(rec_hp < 1) {
      rec_hp = 1; // 最低1は回復する
    }
    actor.recoverHp(rec_hp);

    // 生き返りスキル発動
    {
      var eft = new BtlLogicData(actor.ID, actor.group, BtlLogic.AutoRevive);
      eft.setTarget(actor.ID);
      ret.add(eft);
    }
    {
      var type = BtlLogic.BeginSkill(skillID);
      var eft = new BtlLogicData(actor.ID, actor.group, type);
      ret.add(eft);

      // 自動復活した
      actor.param.bAutoRevive = true;
    }

    // HP回復
    {
      var type = BtlLogic.HpRecover(rec_hp);
      var eft = new BtlLogicData(actor.ID, actor.group, type);
      // 自分自身が対象
      eft.setTarget(actor.ID);
      ret.add(eft);
    }

    return ret;
  }
}
