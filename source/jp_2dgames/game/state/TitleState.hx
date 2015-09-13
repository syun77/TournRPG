package jp_2dgames.game.state;

import jp_2dgames.lib.Input;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

/**
 * タイトルシーン
 **/
class TitleState extends FlxState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    var txt = new FlxText(FlxG.width/2, FlxG.height/2, 128, "Tourn RPG");
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
      FlxG.switchState(new PlayInitState());
    }
  }
}
