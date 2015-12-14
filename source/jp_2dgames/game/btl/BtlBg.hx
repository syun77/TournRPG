package jp_2dgames.game.btl;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * バトル背景
 **/
class BtlBg extends FlxSprite {

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(Reg.getBackImagePath(1), false, 0, 0, true);

    x = FlxG.width/2 - width/2;
    y = FlxG.height/2 - height/2;

    scale.set(1.3, 1.3);
  }


}
