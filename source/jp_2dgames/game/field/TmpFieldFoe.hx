package jp_2dgames.game.field;

private class _FieldFoe {
  public var nodeID:Int;
  public var groupID:Int;

  public function new(nodeID:Int, groupID:Int) {
    this.nodeID = nodeID;
    this.groupID = groupID;
  }
}

/**
 * F.O.E.のセーブデータからの受け取り用
 **/
class TmpFieldFoe {

  // 受け取りリスト
  static var _list:List<_FieldFoe> = null;

  /**
   * 生成
   **/
  public static function create():Void {
    _list = new List<_FieldFoe>();
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
  public static function add(nodeID:Int, groupID:Int):Void {
    var foe = new _FieldFoe(nodeID, groupID);
    _list.add(foe);
  }

  /**
   * FieldFoeにコピーする
   **/
  public static function copyToFieldFoe():Void {
    for(foe in _list) {
      FieldFoe.add(foe.nodeID, foe.groupID);
    }
  }
}
