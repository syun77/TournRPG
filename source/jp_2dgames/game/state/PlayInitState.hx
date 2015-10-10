package jp_2dgames.game.state;

import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.skill.SkillConst;
import flixel.FlxG;
import flixel.FlxState;

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
    var skill = new SkillData(SkillConst.SKILL008);
    skills.push(skill);

    openSubState(new BattleState());
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
//    FlxG.switchState(new FieldState());
  }
}
