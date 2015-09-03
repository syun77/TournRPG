package jp_2dgames.game;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * 背景
 **/
class Bg extends FlxSprite {
  public function new() {
    super(0, 0, Reg.getBackImagePath(1));

    x = FlxG.width/2 - width/2;
    y = FlxG.height/2 - height/2;
  }

}
