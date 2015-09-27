package jp_2dgames.game.state;
import flixel.util.FlxPoint;
import haxe.ds.ArraySort;
import jp_2dgames.game.field.FieldNode;
import flixel.FlxG;
import flixel.util.FlxRandom;
import flixel.FlxState;

/**
 * フィールドシーン
 **/
class FieldState extends FlxState {

  // 現在いるノード
  var _nowNode:FieldNode;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // ノード作成
    FieldNode.createParent(this);

    // ゴール
    FieldNode.add(FlxG.width/2, 32, FieldEvent.Goal);

    var size:Int = 32;
    var imax:Int = Std.int(FlxG.width/size);
    var jmax:Int = Std.int(FlxG.height/size)-1;
    var rnd:Int = 10;
    for(j in 2...jmax) {
      for(i in 1...imax) {
        if(FlxRandom.intRanged(0, rnd) == 0) {
          var px = size * i;
          var py = size * j;
          var ev:FieldEvent = FieldEvent.None;
          var rnd2 = FlxRandom.intRanged(0, 10);
          if(rnd2 < 5) {
            // 何もなし
          }
          else if(rnd2 < 8) {
            // 敵
            ev = FieldEvent.Enemy;
          }
          else {
            // アイテム
            ev = FieldEvent.Item;
          }
          FieldNode.add(px, py, ev);
          rnd += 4;
        }
        else {
          rnd--;
        }
      }
    }

    // スタート地点
    _nowNode = FieldNode.add(FlxG.width/2, FlxG.height-32, FieldEvent.Start);

    // 到達可能な地点を検索
    var nodeList = new Array<FieldNode>();
    FieldNode.forEachAlive(function(node:FieldNode) {
      nodeList.push(node);
    });

    ArraySort.sort(nodeList, function(a:FieldNode, b:FieldNode) {
      var y = Std.int(b.y - a.y) * 100;
      var ax = Math.abs(a.x - _nowNode.x);
      var bx = Math.abs(b.x - _nowNode.x);

      return y + Std.int(ax - bx);
    });

    var cnt:Int = 0;
    for(node in nodeList) {
      if(cnt < 5) {
        node.reachable = true;
        cnt++;

      }
      else {
        node.reachable = false;
      }
    }
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

    var pt = FlxPoint.get(FlxG.mouse.x, FlxG.mouse.y);
    var selNode:FieldNode = null;
    FieldNode.forEachAlive(function(node:FieldNode) {
      node.scale.set(1, 1);
      if(node.reachable == false) {
        // 移動できないところは選べない
        return;
      }
      if(node.evType == FieldEvent.Start) {
        // スタート地点は選べない
        return;
      }

      if(node.overlapsPoint(pt)) {
        selNode = node;
        node.scale.set(1.5, 1.5);
      }
    });

    #if neko
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
    #end
  }
}
