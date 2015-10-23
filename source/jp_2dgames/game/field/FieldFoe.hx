package jp_2dgames.game.field;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * F.O.E.
 **/
class FieldFoe extends FlxSprite {

  // ■定数
  // 描画オフセット(Y)
  static inline var OFS_Y:Int = -12;

  // ■管理オブジェクト
  static var _parent:FlxTypedGroup<FieldFoe> = null;

  /**
   * 生成
   **/
  public static function createParent(state:FlxState):Void {
    _parent = new FlxTypedGroup<FieldFoe>(16);
    for(i in 0..._parent.maxSize) {
      _parent.add(new FieldFoe(i));
    }

    state.add(_parent);
  }

  /**
   * 破棄
   **/
  public static function destroyParent(state:FlxState):Void {
    state.remove(_parent);
  }

  /**
   * 追加
   **/
  public static function add(NodeID:Int, GroupID:Int):FieldFoe {
    var foe:FieldFoe = _parent.recycle();
    foe.init(NodeID, GroupID);
    return foe;
  }

  /**
   * 生存しているF.O.E.を全走査
   **/
  public static function forEachAlive(func:FieldFoe->Void):Void {
    _parent.forEachAlive(func);
  }

  /**
   * 条件に一致するF.O.E.を検索
   **/
  public static function search(func:FieldFoe->Bool):FieldFoe {
    for(foe in _parent.members) {
      if(foe.alive == false) {
        continue;
      }

      if(func(foe)) {
        // 条件に一致
        return foe;
      }
    }

    // 見つからなかった
    return null;
  }

  /**
   * ノードIDに一致するF.O.E.を検索する
   **/
  public static function searchFromNodeID(nodeID:Int):FieldFoe {
    return search(function(foe:FieldFoe) {
      return foe.nodeID == nodeID;
    });
  }

  // ■メンバ変数
  // 現在いるノード
  private var _nodeID:Int;
  public var nodeID(get, never):Int;
  private function get_nodeID() {
    return _nodeID;
  }
  // 敵グループID
  private var _groupID:Int;
  public var groupID(get, never):Int;
  private function get_groupID() {
    return _groupID;
  }

  /**
   * コンストラクタ
   **/
  public function new(idx:Int) {
    super();
    ID = idx;
    loadGraphic(Reg.PATH_FIELD_FOE_ICON, true);
    animation.add("play", [0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1], 4);
    animation.play("play");
    kill();
  }

  /**
   * 初期化
   **/
  public function init(NodeID:Int, GroupID:Int):Void {
    _nodeID = NodeID;
    _groupID = GroupID;
    var node = FieldNode.searchFromID(nodeID);
    if(node == null) {
      return;
    }
    x = node.x;
    y = node.y + OFS_Y;
  }
}
