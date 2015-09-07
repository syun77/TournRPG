package jp_2dgames.game.btl;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * バトル背景
 **/
class BtlBg extends FlxSprite {
  public function new() {
    super(0, 0, Reg.getBackImagePath(1));

    x = FlxG.width/2 - width/2;
    y = FlxG.height/2 - height/2;
  }

}
