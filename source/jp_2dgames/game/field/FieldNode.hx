package jp_2dgames.game.field;

import haxe.ds.ArraySort;
import flixel.util.FlxMath;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * フィールドノード
 **/
class FieldNode extends FlxSprite {

  // ■定数
  public static inline var SIZE:Int = 32;

  // ■管理オブジェクト
  static var _parent:FlxTypedGroup<FieldNode> = null;

  /**
   * 生成
   **/
  public static function createParent(state:FlxState):Void {
    _parent = new FlxTypedGroup<FieldNode>(64);
    for(i in 0..._parent.maxSize) {
      _parent.add(new FieldNode(i));
    }
    state.add(_parent);
  }

  /**
   * 破棄
   **/
  public static function destroyParent(state:FlxState):Void {
    state.remove(_parent);
    _parent = null;
  }

  /**
   * 追加
   **/
  public static function add(X:Float, Y:Float, evType:FieldEvent):FieldNode {
    var node:FieldNode = _parent.recycle();
    node.init(X, Y, evType);
    return node;
  }

  /**
   * 生存しているノードをすべて実行
   **/
  public static function forEachAlive(func:FieldNode->Void):Void {
    _parent.forEachAlive(func);
  }

  /**
   * 指定のノードの近くにあるノードのリストを返す
   **/
  public static function getNearestSortedList(node:FieldNode):Array<FieldNode> {

    var ret = new Array<FieldNode>();

    // 対象となるノードへの距離を求める
    _parent.forEachAlive(function(n:FieldNode) {
      if(node.ID == n.ID) {
        // 同一なので対象外
        return;
      }

      // 距離を求める
      n.distance = FlxMath.distanceBetween(node, n);
      ret.push(n);
    });

    // 近い順にソートする
    ArraySort.sort(ret, function(a:FieldNode, b:FieldNode) {
      return Std.int(a.distance - b.distance);
    });

    return ret;
  }

  /**
   * 移動可能なノードを削除する
   **/
  public static function killReachable(node:FieldNode):Void {

    forEachAlive(function(n:FieldNode) {
      if(n.evType == FieldEvent.Goal) {
        // ゴールは対象外
        return;
      }

      if(n.ID == node.ID) {
        // 選択したノードも対象外
        return;
      }

      if(n.reachable) {
        // 移動可能なノードを削除
        n.kill();
      }
    });
  }

  // 中心座標
  public var xcenter(get, never):Float;
  private function get_xcenter() {
    return x + origin.x;
  }
  public var ycenter(get, never):Float;
  private function get_ycenter() {
    return y + origin.y;
  }

  // 距離 (距離でのソート時に使用)
  private var _distance:Float = 0;
  public var distance(get, set):Float;
  private function get_distance() {
    return _distance;
  }
  private function set_distance(d:Float):Float {
    _distance = d;
    return d;
  }

  // イベント種別
  private var _evType:FieldEvent;
  public var evType(get, never):FieldEvent;
  private function get_evType() {
    return _evType;
  }

  /**
   * イベントを設定
   **/
  public function setEventType(ev:FieldEvent):Void {
    _evType = ev;
    _setColor();
  }

  // 到達可能かどうか
  private var _reachable:Bool = true;
  public var reachable(get, set):Bool;
  private function get_reachable() {
    return _reachable;
  }
  private function set_reachable(b:Bool) {
    if(b) {
      // 到達できる
      color = FlxColor.WHITE;
    }
    else {
      // 到達できない
      color = FlxColor.GRAY;
    }
    _reachable = b;
    return b;
  }

  // 移動可能なノード
  private var _reachableNodes:List<FieldNode>;
  public var reachableNodes(get, never):List<FieldNode>;
  private function get_reachableNodes() {
    return _reachableNodes;
  }

  /**
   * 移動可能なノードを追加
   * @param node 追加するノード
   * @return 追加できたら true
   **/
  public function addReachableNodes(node:FieldNode):Bool {
    for(n in _reachableNodes) {
      if(n.ID == node.ID) {
        // すでに追加済み
        return false;
      }
    }

    _reachableNodes.add(node);
    // 追加できた
    return true;
  }

  /**
   * 移動可能なノードをすべて到達可能にする
   **/
  public function openNodes():Void {
    for(node in _reachableNodes) {
      node.reachable = true;
    }
  }

  /**
   * コンストラクタ
   **/
  public function new(idx:Int) {
    super();
    ID = idx;
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, evType:FieldEvent) {
    x = X;
    y = Y;
    _evType = evType;
    _setColor();

    reachable = false;
    _reachableNodes = new List<FieldNode>();
  }

  /**
   * 色を設定
   **/
  private function _setColor():Void {
    var col:Int = FlxColor.WHITE;
    switch(_evType) {
      case FieldEvent.None:
        col = FlxColor.WHITE;
      case FieldEvent.Start:
        col = MyColor.ASE_LIGHTCYAN;
      case FieldEvent.Goal:
        col = FlxColor.CHARTREUSE;
      case FieldEvent.Enemy:
//        col = FlxColor.SALMON;
      case FieldEvent.Item:
//        col = FlxColor.GOLDENROD;
    }

    loadGraphic(Reg.PATH_FIELD_NODE);
  }
}

