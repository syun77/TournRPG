package jp_2dgames.game;

import flixel.util.FlxAngle;
import jp_2dgames.lib.MyMath;
import jp_2dgames.lib.MyKey;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxState;

/**
 * メインゲーム
 */
class StateMain extends FlxState {

  var _spr:FlxSprite;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    _spr = new FlxSprite(FlxG.width/2, FlxG.height/2).makeGraphic(32, 8, FlxColor.WHITE);
    this.add(_spr);
  }

  /**
	 * 破棄
	 */

  override public function destroy():Void {
    super.destroy();
  }

  /**
	 * 更新
	 */

  override public function update():Void {
    super.update();

    var dx = FlxG.mouse.x - _spr.x;
    var dy = FlxG.mouse.y - _spr.y;
    var aim = Math.atan2(dy, dx) * FlxAngle.TO_DEG;
    var diff = MyMath.deltaAngle(_spr.angle, aim);
    _spr.angle += diff * 0.1;

    if(MyKey.press.A) {
      trace("hoge");
    }

    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
  }
}