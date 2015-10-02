package jp_2dgames.game.field;
import flixel.util.FlxMath;
import flixel.FlxG;
import flixel.util.FlxRandom;

/**
 * フィールドのノード操作ユーティリティ
 **/
class FieldNodeUtil {

  /**
   * 生成
   * @return スタート地点のノード
   **/
  public static function create():FieldNode {

    // ゴール
    var size = FieldNode.SIZE;
    FieldNode.add(size*4, size, FieldEvent.Goal);

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
          if(rnd2 < 3) {
            // 何もなし
          }
          else if(rnd2 < 7) {
            // 敵
            ev = FieldEvent.Enemy;
          }
          else {
            // アイテム
            ev = FieldEvent.Item;
          }
          FieldNode.add(px, py, ev);
          rnd += 2;
        }
        else {
          rnd--;
        }
      }
    }

    // スタート地点
    var ret = FieldNode.add(FlxG.width/2, FlxG.height-32, FieldEvent.Start);
    // 到達可能な地点を検索
    addReachableNode(ret);
    ret.openNodes();

    return ret;
  }

  /**
   * 到達可能な地点を検索
   **/
  public static function addReachableNode(node:FieldNode):Void {

    // 見つけたノードの数
    var cnt:Int = 0;

    FieldNode.forEachAlive(function(n:FieldNode) {
      if(node.ID == n.ID) {
        // 同一ノード
        return;
      }
      var distance = FlxMath.distanceBetween(node, n);
      if(distance < 64) {
        if(node.addReachableNodes(n)) {
          // 追加できた
          cnt++;
        }
      }
    });

    if(cnt > 1) {
      // 接続ノードが2つ以上存在したのでおしまい
      return;
    }

    var nodes = FieldNode.getNearestSortedList(node);
    for(n in nodes) {
      if(node.addReachableNodes(n)) {
        // 追加できた
        cnt++;
        if(cnt >= 2) {
          break;
        }
      }
    }
  }
}
