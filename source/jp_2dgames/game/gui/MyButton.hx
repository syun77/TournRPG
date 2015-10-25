package jp_2dgames.game.gui;
import jp_2dgames.lib.Snd;
import flixel.ui.FlxTypedButton;
import flixel.ui.FlxButton;

/**
 * 拡張ボタン
 **/
class MyButton extends FlxButton {
  private var _enabled:Bool = true;
  public var enabled(get, set):Bool;
  private function set_enabled(b:Bool):Bool {
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
  private function get_enabled():Bool {
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
   * コンストラクタ
   **/
  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void) {
    super(X, Y, Text, OnClick);

    onDown.sound = Snd.load("push");
    scrollFactor.set();
  }

  override private function updateButton():Void {
    if(_enabled) {
      super.updateButton();
    }
  }
}
