package jp_2dgames.game.skill;

import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.btl.BtlGroupUtil;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.skill.SkillRange;
import jp_2dgames.lib.CsvLoader;

/**
 * スキル操作のユーティリティ
 **/
class SkillUtil {

  // 無効なスキルID
  public static inline var NONE:Int = -1;

  // 自動発動スキルIDの開始オフセット
  private static inline var ID_OFFSET:Int = 500;

  // 通常スキル
  private static var _csvSkill:CsvLoader = null;
  // 自動発動スキル
  private static var _csvSkillAuto:CsvLoader = null;
  // スキルタイプ：文字からenumへの変換
  private static var _typeTbl:Map<String,SkillType>;
  // スキル属性：文字からenumへの変換
  private static var _attrTbl:Map<String,SkillAttr>;
  // 攻撃範囲：文字からenumへの変換
  private static var _rangeTbl:Map<String,SkillRange>;

  /**
   * ロード
   **/
  public static function load():Void {
    _csvSkill     = new CsvLoader(Reg.PATH_CSV_SKILL_NORMAL);
    _csvSkillAuto = new CsvLoader(Reg.PATH_CSV_SKILL_AUTO);
    _typeTbl = [
      "ATK_PHY"   => SkillType.AtkPhyscal,
      "ATK_MAG"   => SkillType.AtkMagical,
      "ATK_BST"   => SkillType.AtkBadstatus,
      "RECOVER"   => SkillType.Recover,
      "BUFF"      => SkillType.Buff,
      "AUTO"      => SkillType.Auto,
      "AUTO_ATTR" => SkillType.AutoAttr,
      "AUTO_STUP" => SkillType.AutoStatusUp
    ];
    _attrTbl = [
      "AT_PHY"       => SkillAttr.Physcal,
      "AT_MAG"       => SkillAttr.Magical,
      "AT_POISON"    => SkillAttr.Poision,
      "AT_CONFUSION" => SkillAttr.Confusion,
      "AT_CLOSE"     => SkillAttr.Close,
      "AT_PARALYZE"  => SkillAttr.Paralyze,
      "AT_SLEEP"     => SkillAttr.Sleep,
      "AT_BLIND"     => SkillAttr.Blind,
      "AT_WEAK"      => SkillAttr.Weak
    ];
    _rangeTbl = [
      "SELF"       => SkillRange.Self,
      "FRIEND_ONE" => SkillRange.FriendOne,
      "FRIEND_ALL" => SkillRange.FriendAll,
      "ENEMY_ONE"  => SkillRange.EnemyOne,
      "ENEMY_ALL"  => SkillRange.EnemyAll,
      "ALL"        => SkillRange.All
    ];
  }

  /**
   * 破棄
   **/
  public static function unload():Void {
    _csvSkill     = null;
    _csvSkillAuto = null;
  }

  /**
   * CSVデータを取得する
   **/
  public static function getCsv(skillID:Int):CsvLoader {
    if(isNormal(skillID)) {
      // 通常スキル
      return _csvSkill;
    }
    else {
      // 自動発動
      return _csvSkillAuto;
    }
  }

  /**
   * 通常スキルかどうか
   **/
  public static function isNormal(skillID:Int):Bool {
    if(skillID < ID_OFFSET) {
      // 通常スキル
      return true;
    }
    else {
      // 自動発動スキル
      return false;
    }
  }

  /**
   * 自動発動スキルかどうか
   **/
  public static function isAuto(skillID:Int):Bool {
    return isNormal(skillID) == false;
  }

  /**
   * パラメータを取得する
   **/
  public static function getParam(skillID:Int, key:String):Int {
    var csv = getCsv(skillID);
    return csv.searchItemInt("id", '${skillID}', key, false);
  }
  public static function getParamString(skillID:Int, key:String):String {
    var csv = getCsv(skillID);
    return csv.searchItem("id", '${skillID}', key);
  }

  /**
   * スキル名を取得する
   **/
  public static function getName(skillID:Int):String {
    return getParamString(skillID, "name");
  }

  /**
   * 詳細情報を取得する
   **/
  public static function getDetail(skillID:Int):String {
    return getParamString(skillID, "detail");
  }

  /**
   * 詳細情報(消費コスト付き)を取得する
   **/
  public static function getDetail2(skillID:Int, actor:Actor):String {
    if(isNormal(skillID) == false) {
      // パッシブスキルはコスト表示なし
      return getDetail(skillID);
    }

    var detail = getDetail(skillID);
    var hp = getCostHp(skillID, actor);
    if(hp > 0) {
      return '${detail} (HP -${hp})';
    }
    else {
      var mp = getCostMp(skillID, actor);
      return '${detail} (TP -${mp})';
    }
  }

  // 購入価格
  public static function getBuy(skillID:Int):Int {
    return getParam(skillID, "buy");
  }
  // 売却価格
  public static function getSell(skillID:Int):Int {
    return getParam(skillID, "sell");
  }

  /**
   * スキルコスト(HP)を取得する
   **/
  public static function getCostHp(skillID:Int, actor:Actor):Int {

    var cost = getParam(skillID, "hp");
    if(cost == 0) {
      // HPコストなし
      return 0;
    }
    if(actor == null) {
      return cost;
    }
    if(actor.group == BtlGroup.Player) {
      // コスト減少
      cost -= SkillSlot.getCostSaveHp();
      if(cost < 1) {
        // 1以下にはならない
        cost = 1;
      }
    }
    return cost;
  }

  /**
   * スキルコスト(MP)を取得する
   **/
  public static function getCostMp(skillID:Int, actor:Actor):Int {
    var cost = getParam(skillID, "mp");
    if(cost == 0) {
      // MPコストなし
      return 0;
    }
    if(actor == null) {
      return cost;
    }
    if(actor.group == BtlGroup.Player) {
      // コスト減少
      cost -= SkillSlot.getCostSaveMp();
      if(cost < 1) {
        // 1以下にはならない
        cost = 1;
      }
    }
    return cost;
  }

  /**
   * 指定のスキルを使えるかどうかチェックする
   * @return 使用可能であれば true
   **/
  public static function checkCost(skillID:Int, actor:Actor):Bool {
    var hp = getCostHp(skillID, actor);
    if(hp > 0) {
      // HPコスト
      return hp < actor.hp;
    }
    else {
      // MPコスト
      var mp = getCostMp(skillID, actor);
      return mp <= actor.mp;
    }
  }

  /**
   * 自動復活時のHP回復率を取得する
   **/
  public static function getRevive(skillID:Int):Int {
    if(isAuto(skillID) == false) {
      // パッシブスキルではない
      return 0;
    }

    return getParam(skillID, "revive");
  }

  /**
   * スキル消費コスト(HP)減少値を取得する
   **/
  public static function getCostSaveHp(skillID:Int):Int {
    if(isAuto(skillID) == false) {
      // パッシブスキルではない
      return 0;
    }

    return getParam(skillID, "save_hp");
  }

  /**
   * スキル消費コスト(MP)減少値を取得する
   **/
  public static function getCostSaveMp(skillID:Int):Int {
    if(isAuto(skillID) == false) {
      // パッシブスキルではない
      return 0;
    }

    return getParam(skillID, "save_mp");
  }

  /**
   * 文字列をスキル種別に変換
   **/
  public static function fromTypeString(str:String):SkillType {
    return _typeTbl[str];
  }

  /**
   * スキルIDからスキル種別を求める
   **/
  public static function toType(skillID:Int):SkillType {
    var str = getParamString(skillID, "type");
    if(str == "") {
      // 無効なスキル
      return SkillType.None;
    }

    return fromTypeString(str);
  }

  /**
   * 文字列をスキル属性に変換
   **/
  public static function fromAttributeString(str:String):SkillAttr {
    return _attrTbl[str];
  }

  /**
   * スキルIDからスキル属性を求める
   **/
  public static function toAttribute(skillID:Int):SkillAttr {
    var str = getParamString(skillID, "attr");
    if(str == "") {
      // 無効なスキル
      return SkillAttr.None;
    }

    return fromAttributeString(str);
  }

  /**
   * 付着するバッドステータスを取得する
   **/
  public static function getBadstatus(skillID:Int):BadStatus {
    var str = getParamString(skillID, "bst");
    return BadStatusUtil.fromString2(str);
  }

  /**
   * バッドステータスの付着率を取得する
   * @return 付着する確率 0〜100%
   **/
  public static function getBadstatusHit(skill:Int):Int {
    var ratio = getParam(skill, "bst_hit");
    return ratio;
  }

  /**
   * バッドステータスの威力値を取得する
   **/
  public static function getBadstatusPower(skill:Int):Int {
    var val = getParam(skill, "bst_pow");
    return val;
  }

  /**
   * 文字列を効果範囲に変換
   **/
  public static function fromRangeString(str:String):SkillRange {
    return _rangeTbl[str];
  }

  /**
   * 効果範囲を取得する
   **/
  public static function toRange(skillID:Int):SkillRange {
    var str = getParamString(skillID, "range");
    if(str == "") {
      // 無効なスキル
      return SkillRange.EnemyOne;
    }

    return fromRangeString(str);
  }

  /**
   * バトルの効果範囲に変換する
   **/
  public static function rangeToBtlRange(range:SkillRange):BtlRange {
    switch(range) {
      case SkillRange.Self:
        return BtlRange.Self;
      case SkillRange.FriendOne, SkillRange.EnemyOne:
        return BtlRange.One;
      case SkillRange.FriendAll, SkillRange.EnemyAll:
        return BtlRange.Group;
      case SkillRange.All:
        return BtlRange.All;
    }
  }
}
