package jp_2dgames.game.util;

import jp_2dgames.game.field.FieldNode;
import jp_2dgames.lib.RectLine;
import flixel.FlxState;

/**
 * 線を引く
 **/
class LineMgr {

  var _lines:List<RectLine>;
  public var visible(never, set):Bool;
  private function set_visible(b:Bool) {
    for(line in _lines) {
      line.visible = b;
    }
    return b;
  }
  public var alpha(never, set):Float;
  private function set_alpha(a:Float) {
    for(line in _lines) {
      line.alpha = a;
    }
    return a;
  }

  public function new(state:FlxState, count:Int, color:Int) {
    _lines = new List<RectLine>();
    for(i in 0...count) {
      var line = new RectLine(8, color);
      state.add(line);
      _lines.add(line);
    }
  }

  /**
   * 指定のノード情報で描画する
   **/
  public function drawFromNode(n1:FieldNode, n2:FieldNode):Void {
    for(line in _lines) {
      if(line.visible) {
        // 使用済み
        continue;
      }

      var x1 = n1.xcenter;
      var y1 = n1.ycenter;
      var x2 = n2.xcenter;
      var y2 = n2.ycenter;
      line.drawLine(x1, y1, x2, y2);

      // 描画できた
      break;
    }
  }
}
