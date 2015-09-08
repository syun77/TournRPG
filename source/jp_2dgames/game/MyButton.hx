package jp_2dgames.game;

import openfl.display.BitmapData;
import jp_2dgames.game.MyColor;
import flixel.text.FlxText;
import flixel.ui.FlxTypedButton;

/**
 * 日本語フォントのボタン
 **/
@:bitmap("assets/images/ui/button2.png")
private class GraphicButton extends BitmapData {}
class MyButton extends FlxTypedButton<FlxText> {

  // 幅
  public static inline var WIDTH = 80;
  // 高さ
  public static inline var HEIGHT = 30;

  // ラベルオフセット
  private static inline var LABEL_OFS_X:Int = -1;
  private static inline var LABEL_OFS_Y:Int = 3 + 5;

  /**
	 * Used with public variable status, means not highlighted or pressed.
	 */
  public static inline var NORMAL:Int = 0;
  /**
	 * Used with public variable status, means highlighted (usually from mouse over).
	 */
  public static inline var HIGHLIGHT:Int = 1;
  /**
	 * Used with public variable status, means pressed (usually from mouse click).
	 */
  public static inline var PRESSED:Int = 2;

  /**
	 * Shortcut to setting label.text
	 */
  public var text(get, set):String;

  private var _enabled:Bool = true;
  public var enable(get, set):Bool;
  private function set_enable(b:Bool):Bool {
    _enabled = b;
    if(b) {
      // 有効
      setDefaultColor();
    }
    else {
      // 無効
      color       = MyColor.BTN_DISABLE;
      label.color = MyColor.BTN_DISABLE_LABEL;
    }
    return b;
  }
  private function get_enable():Bool {
    return _enabled;
  }

  /**
   * 初期の色に戻す
   **/
  public function setDefaultColor():Void {
    color       = MyColor.BTN_DEFAULT;
    label.color = MyColor.BTN_DEFAULT_LABEL;
  }

  /**
	 * Creates a new FlxButton object with a gray background
	 * and a callback function on the UI thread.
	 *
	 * @param	X				The X position of the button.
	 * @param	Y				The Y position of the button.
	 * @param	Text			The text that you want to appear on the button.
	 * @param	OnClick			The function to call whenever the button is clicked.
	 */
  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void)
  {
    super(X, Y, OnClick);
    loadGraphic(GraphicButton, true, WIDTH, HEIGHT);

    // ラベルのオフセット座標を設定
    for (point in labelOffsets)
    {
      point.set(point.x + LABEL_OFS_X, point.y + LABEL_OFS_Y);
    }

    initLabel(Text);

    // 有効にしておく
    enable = true;
  }

  /**
	 * Updates the size of the text field to match the button.
	 */
  override private function resetHelpers():Void
  {
    super.resetHelpers();

    if (label != null)
    {
      label.fieldWidth = label.frameWidth = Std.int(width);
      label.size = label.size; // Calls set_size(), don't remove!
    }
  }

  private inline function initLabel(Text:String):Void
  {
    label = new FlxText(x + labelOffsets[NORMAL].x, y + labelOffsets[NORMAL].y, WIDTH, Text);
    // ここでフォントを設定
    label.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S, 0x333333, "center");
    label.alpha = labelAlphas[status];
  }

  private inline function get_text():String
  {
    return label.text;
  }

  private inline function set_text(Text:String):String
  {
    return label.text = Text;
  }

  override private function updateButton():Void {
    if(_enabled) {
      super.updateButton();
    }
  }
}
