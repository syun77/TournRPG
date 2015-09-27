package jp_2dgames.game.field;

import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * イベントの種類
 **/
enum FieldEvent {
  None;  // 何もなし
  Start; // スタート地点
  Goal;  // ゴール地点
  Enemy; // 敵
  Item;  // アイテム
}

/**
 * フィールドノード
 **/
class FieldNode extends FlxSprite {

  static var _parent:FlxTypedGroup<FieldNode> = null;
  public static function createParent(state:FlxState):Void {
    _parent = new FlxTypedGroup<FieldNode>(64);
    for(i in 0..._parent.maxSize) {
      _parent.add(new FieldNode());
    }
    state.add(_parent);
  }

  public static function add(X:Float, Y:Float, evType:FieldEvent):FieldNode {
    var node:FieldNode = _parent.recycle();
    node.init(X, Y, evType);
    return node;
  }

  public static function forEachAlive(func:FieldNode->Void):Void {
    _parent.forEachAlive(func);
  }

  // イベント種別
  private var _evType:FieldEvent;
  public var evType(get, never):FieldEvent;
  private function get_evType() {
    return _evType;
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


  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, evType:FieldEvent) {

    x = X;
    y = Y;
    _evType = evType;

    var col:Int = FlxColor.WHITE;
    switch(_evType) {
      case FieldEvent.None:
        col = FlxColor.WHITE;
      case FieldEvent.Start:
        col = FlxColor.AZURE;
      case FieldEvent.Goal:
        col = FlxColor.CHARTREUSE;
      case FieldEvent.Enemy:
        col = FlxColor.SALMON;
      case FieldEvent.Item:
        col = FlxColor.GOLDENROD;
    }
    makeGraphic(16, 16, col);
  }
}

