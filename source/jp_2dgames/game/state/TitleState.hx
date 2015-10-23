package jp_2dgames.game.state;

import jp_2dgames.game.gui.MyButton2;
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

    var txt = new FlxText(0, 128, FlxG.width, "S.N.P.", 24);
    txt.alignment = "center";
    this.add(txt);

    var px = FlxG.width/2 - MyButton2.WIDTH/2;
    var py = FlxG.height - 128;
    var btn = new MyButton2(px, py, "CLICK TO START", function() {
      FlxG.switchState(new PlayInitState());
    });
    this.add(btn);
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
    
  }
}
