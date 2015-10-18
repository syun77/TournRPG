package jp_2dgames.game.field;

import jp_2dgames.game.field.FieldNodeUtil;
import jp_2dgames.game.field.FieldEvent.FieldEventUtil;

private class _FieldNode {
  public var x:Float;
  public var y:Float;
  public var evType:FieldEvent;
  public var bStart:Bool;
  public var bFoot:Bool;

  public function new(X:Float, Y:Float, ev:String, bStart:Bool, bFoot:Bool) {
    x = X;
    y = Y;
    evType = FieldEventUtil.fromString(ev);
    this.bStart = bStart;
    this.bFoot  = bFoot;
  }
}

/**
 * Fieldノードのセーブデータからの受け取り用
 **/
class TmpFieldNode {

  // 受け取りリスト
  static var _list:List<_FieldNode> = null;

  /**
   * 生成
   **/
  public static function create():Void {
    _list = new List<_FieldNode>();
  }

  /**
   * 破棄
   **/
  public static function destroy():Void {
    _list = null;
  }

  /**
   * 追加
   **/
  public static function add(x:Float, y:Float, ev:String, bStart:Bool, bFoot):Void {
    var node = new _FieldNode(x, y, ev, bStart, bFoot);
    _list.add(node);
  }

  /**
   * FieldNodeにコピーする
   **/
  public static function copyToFieldNode():Void {
    for(n in _list) {
      var node = FieldNode.add(n.x, n.y, n.evType);
      node.setStartFlag(n.bStart);
      node.setFoot(n.bFoot);
    }

    // 到達可能な地点を検索
    FieldNode.forEachAlive(function(n:FieldNode) {
      FieldNodeUtil.addReachableNode(n);
    });
  }
}
