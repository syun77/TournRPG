package jp_2dgames.game.state;
import flixel.FlxG;
import jp_2dgames.game.actor.EnemyInfo;
import jp_2dgames.game.actor.PlayerInfo;
import flixel.FlxState;

/**
 * ゲーム開始シーン
 **/
class PlayInitState extends FlxState{
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // プレイヤーパラメータロード
    PlayerInfo.load();
    // 敵パラメータロード
    EnemyInfo.load();

    // ゲームグローバルパラメータ初期化
    Global.init();
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
    FlxG.switchState(new PlayState());
  }
}
