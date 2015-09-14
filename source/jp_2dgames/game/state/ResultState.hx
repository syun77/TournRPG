package jp_2dgames.game.state;
import jp_2dgames.lib.Input;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

/**
 * リザルト画面
 **/
class ResultState extends FlxState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    var txt = new FlxText(0, FlxG.height/2, FlxG.width, "Result", 24);
    txt.alignment = "center";
    this.add(txt);
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

    if(Input.press.A) {
      FlxG.switchState(new TitleState());
    }
  }
}
