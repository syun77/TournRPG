package jp_2dgames.game.state;
import jp_2dgames.lib.Input;
import flixel.FlxSubState;

/**
 * ショップ画面
 **/
class ShopState extends FlxSubState {

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(Input.press.B) {
      // TODO: 閉じる
      close();
    }
  }
}
