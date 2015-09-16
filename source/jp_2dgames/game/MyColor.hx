package jp_2dgames.game;
import flixel.util.FlxColor;

/**
 * 色関連の情報
 **/
class MyColor {
  // ■アイテムリスト
  // 選択可能
  public static inline var LISTITEM_ENABLE:Int = 0x006666;
  // 選択不可
  public static inline var LISTITEM_DISABLE:Int = 0x003333;
  // テキストの色
  public static inline var LISTITEM_TEXT:Int = 0x99FFCC;
  public static inline var CURSOR:Int = FlxColor.YELLOW;

  public static inline var COMMAND_FRAME:Int   = 0x00CCCC;
  public static inline var COMMAND_CURSOR:Int  = 0x33CCCC;
  public static inline var COMMAND_DISABLE:Int = 0x999999;
  public static inline var COMMAND_TEXT_SELECTED:Int = 0x000066;
  public static inline var COMMAND_TEXT_UNSELECTED:Int = 0x99FFCC;

  public static inline var DETAIL_FRAME:Int = 0x000033;
  public static inline var MESSAGE_WINDOW:Int = 0x000033;

  public static inline function strToColor(str:String):Int {
    switch(str) {
      case "white": return FlxColor.WHITE;
      case "red": return FlxColor.PINK;
      case "green": return FlxColor.LIME;
      case "blue": return FlxColor.AQUAMARINE;
      case "yellow": return FlxColor.YELLOW;
      case "orange": return FlxColor.WHEAT;
      default:
        return FlxColor.BLACK;
    }
  }

  // ボタン(デフォルト)
  public static inline var BTN_DEFAULT       = FlxColor.WHITE;
  public static inline var BTN_DEFAULT_LABEL = FlxColor.BLACK;

  // ボタン(無効)
  public static inline var BTN_DISABLE       = FlxColor.GRAY;
  public static inline var BTN_DISABLE_LABEL = FlxColor.BLACK;

  // ボタン(装備)
  public static inline var BTN_EQUIP         = FlxColor.MAUVE;
  public static inline var BTN_EQUIP_LABEL   = FlxColor.BLACK;

  // ボタン(消費アイテム)
  public static inline var BTN_CONSUME       = FlxColor.LIME;
  public static inline var BTN_CONSUME_LABEL = FlxColor.BLACK;

  // ボタン(キャンセル)
  public static inline var BTN_CANCEL        = FlxColor.SILVER;
  public static inline var BTN_CANCEL_LABEL  = FlxColor.BLACK;

  // 数値
  // ダメージ
  public static inline var NUM_DAMAGE = FlxColor.SILVER;
  // MISS
  public static inline var NUM_MISS   = FlxColor.AQUAMARINE;
}

