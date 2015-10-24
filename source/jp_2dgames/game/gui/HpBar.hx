package jp_2dgames.game.gui;
import flixel.util.FlxColor;
import jp_2dgames.lib.StatusBar;

/**
 * HPゲージ
 **/
class HpBar extends StatusBar {
  public function new(px:Float, py:Float, w:Int, h:Int) {
    super(px, py, w, h);
    createGradientBar(
      [FlxColor.CHARCOAL, FlxColor.CHARCOAL],
      [FlxColor.WHEAT, FlxColor.CORAL], 2);
  }
}
