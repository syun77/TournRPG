package jp_2dgames.game.state;
import flixel.FlxState;
import jp_2dgames.game.skill.SkillConst;
import jp_2dgames.game.skill.SkillData;
import flixel.FlxG;

/**
 * ゲーム開始シーン
 **/
class PlayInitState extends FlxState {
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // ゲームグローバルパラメータ初期化
    Global.init();

    // 初期スキルを設定
    var skills = Global.getSkillSlot();
    skills.push(new SkillData(SkillConst.SKILL001));
    skills.push(new SkillData(SkillConst.SKILL003));
  }

  /**
   * 破棄
   */
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();

    // ゲーム開始
//    FlxG.switchState(new PlayState());
    FlxG.switchState(new FieldState());
  }
}
