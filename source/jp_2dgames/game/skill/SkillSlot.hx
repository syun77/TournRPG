package jp_2dgames.game.skill;

/**
 * スキルスロット
 **/
class SkillSlot {

  // スキルスロットの最大数
  private static inline var LIMIT_FIRST:Int = 3;

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
   * 指定の番号のスキルを取得する
   **/
  public static function getSkill(idx:Int):SkillData {
    return _instance._getSkill(idx);
  }

  /**
   * スキルを追加
   **/
  public static function addSkill(skill:SkillData):Void {
    return _instance._addSkill(skill);
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
  private function _addSkill(skill:SkillData):Void {
    skillList.push(skill);
  }

}
