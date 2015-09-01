package jp_2dgames.game;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.ui.FlxTypedButton;

/**
 * 日本語フォントのボタン
 **/
class MyButton extends FlxTypedButton<FlxText> {
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
  public var enabled(never, set):Bool;
  private function set_enabled(b:Bool):Bool {
    _enabled = b;
    if(b) {
      // 有効
      color = FlxColor.WHITE;
      label.color = FlxColor.BLACK;
    }
    else {
      // 無効
      color = FlxColor.GRAY;
      label.color = FlxColor.BLACK;
    }
    return b;
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

    for (point in labelOffsets)
    {
      point.set(point.x - 1, point.y + 3);
    }

    initLabel(Text);

    // 有効にしておく
    enabled = true;
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
    label = new FlxText(x + labelOffsets[NORMAL].x, y + labelOffsets[NORMAL].y, 80, Text);
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
