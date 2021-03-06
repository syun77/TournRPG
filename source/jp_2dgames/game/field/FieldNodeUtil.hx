package jp_2dgames.game.field;
import jp_2dgames.game.field.FieldEffectUtil.FieldEffect;
import flixel.util.FlxAngle;
import flixel.util.FlxMath;
import flixel.FlxG;
import flixel.util.FlxRandom;

/**
 * フィールドのノード操作ユーティリティ
 **/
class FieldNodeUtil {

  private static inline var REACHABLE_DISTANCE:Int = 80;
  private static inline var LIMIT_Y:Int = 144;
  private static inline var NEAR_DISTANCE:Int = 28;

  // 配置できなかったときのリトライ回数
  private static inline var RETRY_COUNT:Int = 12;

  /**
   * 生成
   * @return スタート地点のノード
   **/
  public static function create():FieldNode {

    // スタート地点
    var nodeStart = FieldNode.add(FlxG.width/2, FlxG.height-60, FieldEvent.None, FieldEffect.None);
    nodeStart.setStartFlag(true);

    var tmpNode = _createWay(nodeStart);
    _createWay(nodeStart);
    _createWay(nodeStart);
    if(FieldNode.countLiving() < 16) {
      // ノード数が少ないので追加で作る
      _createWay(nodeStart);
    }

    // ゴールを設定
    var nodeList = new Array<FieldNode>();
    FieldNode.forEachAlive(function(n:FieldNode) {
      if(n.y < FlxG.height/2) {
        nodeList.push(n);
      }
    });
    var length = nodeList.length;
    if(length > 0) {
      var idx = FlxRandom.intRanged(0, length-1);
      var node = nodeList[idx];
      node.setEventType(FieldEvent.Goal);
      node.reachable = false;
    }
    else {
      // 念のため
      tmpNode.setEventType(FieldEvent.Goal);
      tmpNode.reachable = false;
    }

    // 0〜2:  None
    // 3〜6:  Enemy
    // 7〜10: Item
    FieldNode.forEachAlive(function(n:FieldNode) {
      if(n.evType == FieldEvent.None) {
        var rnd = FlxRandom.intRanged(0, 10);
        switch(rnd) {
          case 0,1,2:
            n.setEventType(FieldEvent.None);
          case 3,4,5,6:
            n.setEventType(FieldEvent.Enemy);
          case 7,8,9,10:
            n.setEventType(FieldEvent.Item);
        }
      }
    });

    // 到達可能な地点を検索
    FieldNode.forEachAlive(function(n:FieldNode) {
      addReachableNode(n);
    });

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

  /**
   * 道を作る
   **/
  private static function _createWay(nodeStart:FieldNode):FieldNode {

    var node:FieldNode = nodeStart;
    var angle:Float = -1;
    var prevDeg:Float = 0;

    var px:Float = 0;
    var py:Float = 0;
    var idx:Int = 0;
    while(true) {
      px = node.x;
      py = node.y;
      var distance = FlxRandom.floatRanged(REACHABLE_DISTANCE*0.7, REACHABLE_DISTANCE);
      var deg = FlxRandom.floatRanged(45-angle, 135+angle);
      if(0 < prevDeg && prevDeg < 90) {
        deg = FlxRandom.floatRanged(135, 135+angle);
      }
      else if(90 < prevDeg && prevDeg < 180) {
        deg = FlxRandom.floatRanged(45-angle, 45);
      }
      px += distance * Math.cos(deg * FlxAngle.TO_RAD);
      py += distance * -Math.sin(deg * FlxAngle.TO_RAD);

      if(_checkRetry(px, py)) {
        // やり直し
        idx++;
        // 生成可能角度を広げる
        angle += 2;
        if(idx >= RETRY_COUNT) {
          // 配置できなかった
          return node;
        }

        // 全快の角度を保存
        prevDeg = deg;
        continue;
      }

      // ランダム配置可能
      node = FieldNode.add(px, py, FieldEvent.None, FieldEffect.None);
      break;
    }

    if(node.y > LIMIT_Y) {
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

    // 到達可能地点をクリア
    node.reachableNodes.clear();

    FieldNode.forEachAlive(function(n:FieldNode) {
      if(node.ID == n.ID) {
        // 同一ノード
        return;
      }
      var distance = FlxMath.distanceBetween(node, n);
      if(distance <= REACHABLE_DISTANCE) {
        if(node.addReachableNodes(n)) {
          // 追加できた
        }
      }
    });
  }

  /**
   * 移動経路の描画
   **/
  public static function drawReachableWay(fnDraw:FieldNode->FieldNode->Void):Void {

    var map = new Map<Int, Int>();
    FieldNode.forEachAlive(function(n1:FieldNode) {

      for(n2 in n1.reachableNodes) {
        var check = function() {
          if(map.exists(n1.ID)) {
            return map[n2.ID] == n2.ID;
          }
          if(map.exists(n2.ID)) {
            return map[n1.ID] == n1.ID;
          }

          // 存在しない組み合わせ
          return false;
        }

        if(check()) {
          // すでに存在している
          return;
        }

        // 存在していないので描画する
        fnDraw(n1, n2);

        // 描画済み
        map[n1.ID] = n2.ID;
      }
    });
  }
}
