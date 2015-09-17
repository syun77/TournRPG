package jp_2dgames.game.skill;

import jp_2dgames.lib.CsvLoader;

/**
 * スキル操作のユーティリティ
 **/
class SkillUtil {

  // 自動発動スキルIDの開始オフセット
  private static inline var ID_OFFSET:Int = 500;

  // 通常スキル
  private static var _csvSkill:CsvLoader = null;
  // 自動発動スキル
  private static var _csvSkillAuto:CsvLoader = null;

  /**
   * ロード
   **/
  public static function load():Void {
    _csvSkill     = new CsvLoader(Reg.PATH_CSV_SKILL_NORMAL);
    _csvSkillAuto = new CsvLoader(Reg.PATH_CSV_SKILL_AUTO);
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
}
