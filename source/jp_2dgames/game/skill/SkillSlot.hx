package jp_2dgames.game.skill;

import jp_2dgames.game.actor.Actor;

/**
 * スキルスロット
 **/
class SkillSlot {

  // スキルスロットの最大数
  private static inline var LIMIT_FIRST:Int = 5;

  // ■static変数
  // シングルトン
  private static var _instance:SkillSlot = null;

  // ■static関数
  /**
   * 生成
   **/
  public static function create(skillList:Array<SkillData>):Void {
    _instance = new SkillSlot(skillList);
  }

  /**
   * 破棄
   **/
  public static function destroy():Void {
    _instance = null;
  }

  /**
   * スキル所持の限界かどうか
   **/
  public static function isLimit():Bool {
    return count() >= LIMIT_FIRST;
  }

  /**
   * スキルリストを設定する
   **/
  public static function setSkillList(skillList:Array<SkillData>):Void {
    _instance._init(skillList);
  }

  /**
   * 所持スキル数を取得する
   **/
  public static function count():Int {
    return _instance._countSkill();
  }

  /**
   * スキルを所持していないかどうか
   **/
  public static function isEmpty():Bool {
    return count() <= 0;
  }

  /**
   * 指定の番号のスキルを取得する
   **/
  public static function getSkill(idx:Int):SkillData {
    return _instance._getSkill(idx);
  }

  /**
   * スキルを追加
   **/
  public static function addSkill(skill:SkillData, actor:Actor):Void {
    if(isLimit()) {
      // 限界に達している
      return;
    }

    return _instance._addSkill(skill, actor);
  }

  /**
   * スキルを削除
   **/
  public static function delSkill(idx:Int, actor:Actor):Void {
    return _instance._delSkill(idx, actor);
  }

  /**
   * 属性ブースト値を取得する
   **/
  public static function getBoost(attr:SkillAttr):Float {
    return _instance._getBoost(attr);
  }

  /**
   * 属性耐性値を取得する
   **/
  public static function getRegist(attr:SkillAttr):Float {
    return _instance._getRegist(attr);
  }

  /**
   * ターン終了時の自動HP回復量の取得
   **/
  public static function getTurnEndRecoveryHp():Int {
    return _instance._getTurnEndRecoveryHp();
  }

  /**
   * ターン終了時の自動MP回復量の取得
   **/
  public static function getTurnEndRecoveryMp():Int {
    return _instance._getTurnEndRecoveryMp();
  }

  /**
   * バトル終了時の自動HP回復量の取得
   **/
  public static function getBattleEndRecoveryHp():Int {
    return _instance._getBattleEndRecoveryHp();
  }

  /**
   * バトル終了時の自動MP回復量の取得
   **/
  public static function getBattleEndRecoveryMp():Int {
    return _instance._getBattleEndRecoveryMp();
  }

  /**
   * 死亡時の自動復活で回復するスキルIDを取得する
   * @return 復活できない場合は0
   **/
  public static function getReviveSkillID():Int {
    return _instance._getReviveSkillID();
  }

  public static function getCostSaveHp():Int {
    return _instance._getCostSaveHp();
  }

  public static function getCostSaveMp():Int {
    return _instance._getCostSaveMp();
  }


  // ================================================
  // ■以下インスタンス変数
  // ================================================
  // スキルリスト
  var _skillList:Array<SkillData>;
  public var skillList(get, never):Array<SkillData>;
  private function get_skillList() {
    return _skillList;
  }

  /**
   * コンストラクタ
   **/
  public function new(skillList:Array<SkillData>) {
    _init(skillList);
  }

  /**
   * 初期化
   **/
  private function _init(skillList:Array<SkillData>):Void {
    _skillList = skillList;
  }

  /**
   * まとめて実行する
   **/
  private function _forEach(func:SkillData->Void):Void {
    for(skill in _skillList) {
      func(skill);
    }
  }

  /**
   * スキル所持数を取得する
   **/
  private function _countSkill():Int {
    return skillList.length;
  }

  /**
   * 指定の番号に対応するスキルデータを取得する
   **/
  private function _getSkill(idx:Int):SkillData {
    return skillList[idx];
  }

  /**
   * スキルを追加
   **/
  private function _addSkill(skill:SkillData, actor:Actor):Void {
    skillList.push(skill);
    if(skill.type == SkillType.AutoStatusUp) {
      // 自動ステータス上昇
      _autoStatusUp(skill, actor);
    }
  }

  /**
   * スキルを削除
   **/
  private function _delSkill(idx:Int, actor:Actor):Void {
    var skill = skillList[idx];
    skillList.splice(idx, 1);
    if(skill.type == SkillType.AutoStatusUp) {
      // 自動ステータス上昇を解除
      _delAutoStatusUp(skill, actor);
    }
  }

  /**
   * 自動ステータス上昇
   **/
  private function _autoStatusUp(skill:SkillData, actor:Actor):Void {

    if(skill.type != SkillType.AutoStatusUp) {
      // ステータス上昇スキルではない
      return;
    }

    var hp = SkillUtil.getParam(skill.id, "hp");
    var mp = SkillUtil.getParam(skill.id, "mp");
    var str = SkillUtil.getParam(skill.id, "str");
    var vit = SkillUtil.getParam(skill.id, "vit");
    var agi = SkillUtil.getParam(skill.id, "agi");
    var mag = SkillUtil.getParam(skill.id, "mag");

    actor.param.hpmax += hp;
    actor.param.mpmax += mp;
    actor.param.str   += str;
    actor.param.vit   += vit;
    actor.param.agi   += agi;
    actor.param.mag   += mag;
  }

  /**
   * 自動ステータス上昇の解除
   **/
  private function _delAutoStatusUp(skill:SkillData, actor:Actor):Void {

    if(skill.type != SkillType.AutoStatusUp) {
      // ステータス上昇スキルではない
      return;
    }

    var hp = SkillUtil.getParam(skill.id, "hp");
    var mp = SkillUtil.getParam(skill.id, "mp");
    var str = SkillUtil.getParam(skill.id, "str");
    var vit = SkillUtil.getParam(skill.id, "vit");
    var agi = SkillUtil.getParam(skill.id, "agi");
    var mag = SkillUtil.getParam(skill.id, "mag");

    actor.param.hpmax -= hp;
    actor.param.mpmax -= mp;
    actor.param.str   -= str;
    actor.param.vit   -= vit;
    actor.param.agi   -= agi;
    actor.param.mag   -= mag;
    actor.clampHp();
    actor.clampMp();
  }

  /**
   * 属性ブースト値を取得する
   **/
  private function _getBoost(attr:SkillAttr):Float {
    var ratio:Float = 1;
    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.AutoAttr) {
        if(skill.attr == attr) {
          var boost = SkillUtil.getParam(skill.id, "boost");
          ratio += (boost * 0.01);
        }
      }
    });

    return ratio;
  }

  /**
   * 属性耐性値を取得する
   **/
  private function _getRegist(attr:SkillAttr):Float {
    var ratio:Float = 1;
    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.AutoAttr) {
        if(skill.attr == attr) {
          var regist = SkillUtil.getParam(skill.id, "regist");
          ratio -= (regist * 0.01);
        }
      }
    });

    if(ratio < 0) {
      return 0;
    }
    return ratio;
  }

  /**
   * ターン終了時に回復するHP量の取得
   **/
  private function _getTurnEndRecoveryHp():Int {
    var val:Int = 0;
    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.Auto) {
        var rec_hp = SkillUtil.getParam(skill.id, "rec_hp");
        val += rec_hp;
      }
    });

    return val;
  }

  /**
   * ターン終了時に回復するMP量の取得
   **/
  private function _getTurnEndRecoveryMp():Int {
    var val:Int = 0;
    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.Auto) {
        var rec_mp = SkillUtil.getParam(skill.id, "rec_mp");
        val += rec_mp;
      }
    });

    return val;
  }

  /**
   * バトル終了時の自動HP回復量の取得
   **/
  public function _getBattleEndRecoveryHp():Int {
    var val:Int = 0;
    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.Auto) {
        var win_hp = SkillUtil.getParam(skill.id, "win_hp");
        val += win_hp;
      }
    });

    return val;
  }

  /**
   * バトル終了時の自動MP回復量の取得
   **/
  public function _getBattleEndRecoveryMp():Int {
    var val:Int = 0;
    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.Auto) {
        var win_mp = SkillUtil.getParam(skill.id, "win_mp");
        val += win_mp;
      }
    });

    return val;
  }

  /**
   * 自動復活で回復するHPの割合を取得する
   **/
  private function _getReviveSkillID():Int {

    var skillID:Int = 0;
    var val = 0;

    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.Auto) {
        var recoveryHp = SkillUtil.getRevive(skill.id);
        if(recoveryHp > 0) {
          // 復活スキル
          if(recoveryHp > val) {
            skillID = skill.id;
            // 最大回復値を更新
            val = recoveryHp;
          }
        }
      }
    });

    return skillID;
  }

  /**
   * スキル消費コスト(HP)を下げる値を取得
   **/
  private function _getCostSaveHp():Int {
    var val = 0;

    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.Auto) {
        val += SkillUtil.getCostSaveHp(skill.id);
      }
    });

    return val;
  }

  /**
   * スキル消費コスト(MP)を下げる値を取得
   **/
  private function _getCostSaveMp():Int {
    var val = 0;

    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.Auto) {
        val += SkillUtil.getCostSaveMp(skill.id);
      }
    });

    return val;
  }
}
