package jp_2dgames.game.btl.logic;

/**
 * バトル演出管理(キュー)
 **/
class BtlLogicMgr {
  private static var _instance:BtlLogicMgr = null;

  public static function create():Void {
    if(_instance == null) {
      _instance = new BtlLogicMgr();
    }
  }
  public static function destroy():Void {
    _instance = null;
  }

  public static function push(data:BtlLogicData):Void {
    _instance._push(data);
  }
  private function _push(data:BtlLogicData):Void {
    _pool.add(data);
  }
  public static function pop():BtlLogicData {
    return _instance._pop();
  }
  private function _pop():BtlLogicData {
    return _pool.pop();
  }

  // ■メンバ変数
  var _pool:List<BtlLogicData>;

  public function new() {
    _pool = new List<BtlLogicData>();
  }
}
