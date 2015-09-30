package jp_2dgames.lib;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * 線の描画
 **/
class RectLine extends FlxSpriteGroup {
  public function new(size:Int) {
    super();
    for(i in 0...size) {
      var spr = new FlxSprite(0, 0).makeGraphic(2, 2, FlxColor.WHITE);
      this.add(spr);
    }
    visible = false;
  }

  /**
   * 色の設定
   **/
  public function setColor(c:Int):Void {
    forEachAlive(function(spr:FlxSprite) {
      spr.color = c;
    });
  }

  /**
   * 線の描画
   **/
  public function drawLine(x1:Float, y1:Float, x2:Float, y2:Float):Void {

    var dx = (x2 - x1) / members.length;
    var dy = (y2 - y1) / members.length;

    var px = x1;
    var py = y1;
    forEachAlive(function(spr:FlxSprite) {
      spr.x = px;
      spr.y = py;
      px += dx;
      py += dy;
    });

    visible = true;
  }
}

