package jp_2dgames.game.field;
import flixel.util.FlxAngle;
import flixel.util.FlxMath;
import flixel.FlxG;
import flixel.util.FlxRandom;

/**
 * フィールドのノード操作ユーティリティ
 **/
class FieldNodeUtil {

  private static inline var REACHABLE_DISTANCE:Int = 64;
  private static inline var GOAL_Y:Int = 104;
  private static inline var NEAR_DISTANCE:Int = 32;

  // 配置できなかったときのリトライ回数
  private static inline var RETRY_COUNT:Int = 16;

  /**
   * 生成
   * @return スタート地点のノード
   **/
  public static function create():FieldNode {

    // スタート地点
    var nodeStart = FieldNode.add(FlxG.width/2, FlxG.height-64, FieldEvent.Start);

    _createWay(nodeStart);
    _createWay(nodeStart);
    var node = _createWay(nodeStart);
    // ゴールを設定
    node.setEventType(FieldEvent.Goal);

    // 0〜2:  None
    // 3〜6:  Enemy
    // 7〜10: Item

    // 到達可能な地点を検索
    addReachableNode(nodeStart);
    nodeStart.openNodes();

    return nodeStart;
  }

  /**
   * リトライが必要かどうか
   **/
  private static function _checkRetry(px:Float, py:Float):Bool {

    if(px < 32) {
      // 画面外なのでやり直し
      return true;
    }

    if(px > FlxG.width-32) {
      // 画面外なのでやり直し
      return true;
    }

    // 近くにあるノードを検索
    var n = FieldNode.search(function(n:FieldNode) {
      var dx = n.x - px;
      var dy = n.y - py;
      var d = Math.sqrt((dx*dx) + (dy*dy));
      if(d < NEAR_DISTANCE) {
        // 近くに別のノードがある
        return true;
      }
      return false;
    });

    if(n != null) {
      // 近くにノードがあるのでやり直し
      return true;
    }

    // やり直し不要
    return false;
  }

  private static function _createWay(nodeStart:FieldNode):FieldNode {

    var node:FieldNode = nodeStart;
    var angle:Float = 0;

    var px:Float = 0;
    var py:Float = 0;
    var idx:Int = 0;
    while(true) {
      px = node.x;
      py = node.y;
      var distance = FlxRandom.floatRanged(REACHABLE_DISTANCE*0.7, REACHABLE_DISTANCE);
      var deg = FlxRandom.floatRanged(45-angle, 135+angle);
      px += distance * Math.cos(deg * FlxAngle.TO_RAD);
      py += distance * -Math.sin(deg * FlxAngle.TO_RAD);

      if(_checkRetry(px, py)) {
        // やり直し
        idx++;
        // 生成可能角度を広げる
        angle += 5;
        if(idx >= RETRY_COUNT) {
          // 配置できなかった
          return node;
        }

        continue;
      }

      // ランダム配置可能
      node = FieldNode.add(px, py, FieldEvent.None);
      break;
    }

    if(node.y > GOAL_Y) {
      return _createWay(node);
    }
    else {
      return node;
    }
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
      if(distance < REACHABLE_DISTANCE) {
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
