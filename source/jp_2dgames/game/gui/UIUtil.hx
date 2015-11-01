package jp_2dgames.game.gui;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;

/**
 * UI生成のユーティリティ
 **/
class UIUtil {

  public static var MENU_BG_OFS_Y:Int = 0;

  /**
   * 値段の背景を生成
   **/
  public static function createPriceBG(px:Float, py:Float):FlxSprite {
    var bg = new FlxSprite(px, py+24);
    bg.makeGraphic(MyButton2.WIDTH, 12, MyColor.ASE_NAVY);
    bg.alpha = 0.5;

    return bg;
  }

  /**
   * 値段のテキストを生成
   **/
  public static function createPriceText(px:Float, py:Float, label:String):FlxText {
    var txt = new FlxText(px, py+24, MyButton2.WIDTH);
    txt.text = label;
    txt.alignment = "center";
    txt.color = MyColor.ASE_YELLOW;
    txt.setBorderStyle(FlxText.BORDER_SHADOW);

    return txt;
  }

  /**
   * メニュー背景の生成
   **/
  public static function createMenuBG(px:Float, py:Float):FlxSprite {
    var bg = new FlxSprite(px, py);
    bg.loadGraphic(Reg.PATH_MENU_BG);
    bg.x = FlxG.width/2;
    bg.scale.x = 80;
    bg.alpha = 0.5;

    return bg;
  }
}
