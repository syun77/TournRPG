package jp_2dgames.game.state;

import jp_2dgames.game.gui.message.UIMsg;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.actor.EnemyInfo;
import jp_2dgames.game.actor.PlayerInfo;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.lib.SprFont;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 起動開始シーン
 **/
class BootState extends FlxState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // スプライトフォントのパスを設定する
    SprFont.setBmpPath(Reg.PATH_SPR_FONT);

    // UIテキスト読み込み
    UIMsg.load();

    // アイテムパラメータロード
    ItemUtil.load();
    // プレイヤーパラメータロード
    PlayerInfo.load();
    // 敵パラメータロード
    EnemyInfo.load();
    // スキルパラメータロード
    SkillUtil.load();


    // デバッグ有効
    FlxG.debugger.toggleKeys = ["ALT"];
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

     FlxG.switchState(new PlayInitState());
//   FlxG.switchState(BtlEndResult TitleState());
//    FlxG.switchState(FieldFoe ResultState());
  }
}
