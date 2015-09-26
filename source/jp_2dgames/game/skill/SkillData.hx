package jp_2dgames.game.skill;

/**
 * スキル情報
 **/
class SkillData {

  public var id:Int         = SkillUtil.NONE; // スキルID
  public var type:SkillType = SkillType.None; // スキル種別

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
    id   = skillID;
    type = SkillUtil.toType(skillID);
  }
}
