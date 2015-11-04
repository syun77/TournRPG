package jp_2dgames.game.skill;

/**
 * スキル情報
 **/
class SkillData {

  // スキルID
  public var id:Int = SkillUtil.NONE;
  // スキル種別
  private var _type:SkillType = SkillType.None;
  public var type(get, never):SkillType;
  private function get_type() {
    return _type;
  }
  // スキル属性
  private var _attr:SkillAttr;
  public var attr(get, never):SkillAttr;
  private function get_attr() {
    return _attr;
  }

  /**
   * コンストラクタ
   * @param skillID スキルID
   **/
  public function new(skillID:Int=SkillUtil.NONE) {
    if(skillID == SkillUtil.NONE) {
      return;
    }

    setSkillID(skillID);
  }

  /**
   * スキルIDを設定
   **/
  public function setSkillID(skillID:Int):Void {
    id    = skillID;
    _type = SkillUtil.toType(skillID);
    _attr = SkillUtil.toAttribute(skillID);
  }

}
