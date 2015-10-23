package jp_2dgames.game.gui;
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

  override private function updateButton():Void {
    if(_enabled) {
      super.updateButton();
    }
  }
}
