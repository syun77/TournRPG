package jp_2dgames.game.field;

import jp_2dgames.game.field.FieldEffectUtil;
import jp_2dgames.game.field.FieldNodeUtil;
import jp_2dgames.game.field.FieldEvent.FieldEventUtil;

private class _FieldNode {
  public var x:Float;
  public var y:Float;
  public var evType:FieldEvent;
  public var eftType:FieldEffect;
  public var bStart:Bool;
  public var bFoot:Bool;
  public var bOpened:Bool;

  public function new(X:Float, Y:Float, ev:String, eft:String, bStart:Bool, bFoot:Bool, bOpened:Bool) {
    x = X;
    y = Y;
    evType = FieldEventUtil.fromString(ev);
    eftType = FieldEffectUtil.fromString(eft);
    this.bStart  = bStart;
    this.bFoot   = bFoot;
    this.bOpened = bOpened;
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
  public static function add(x:Float, y:Float, ev:String, eft:String, bStart:Bool, bFoot:Bool, bOpened:Bool):Void {
    var node = new _FieldNode(x, y, ev, eft, bStart, bFoot, bOpened);
    _list.add(node);
  }

  /**
   * FieldNodeにコピーする
   **/
  public static function copyToFieldNode():Void {
    for(n in _list) {
      var node = FieldNode.add(n.x, n.y, n.evType, n.eftType);
      node.setStartFlag(n.bStart);
      node.setFoot(n.bFoot);
      node.setOpened(n.bOpened);
    }

    // 到達可能な地点を検索
    FieldNode.forEachAlive(function(n:FieldNode) {
      FieldNodeUtil.addReachableNode(n);
    });
  }
}
