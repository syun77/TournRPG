package jp_2dgames.game.btl;

/**
 * バトル演出管理(キュー)
 **/
class BtlEffectMgr {
  private static var _instance:BtlEffectMgr = null;

  public static function create():Void {
    if(_instance == null) {
      _instance = new BtlEffectMgr();
    }
  }
  public static function destroy():Void {
    _instance = null;
  }

  public static function push(data:BtlEffectData):Void {
    _instance._push(data);
  }
  private function _push(data:BtlEffectData):Void {
    _pool.add(data);
  }
  public static function pop():BtlEffectData {
    return _instance._pop();
  }
  private function _pop():BtlEffectData {
    return _pool.pop();
  }

  // ■メンバ変数
  var _pool:List<BtlEffectData>;

  public function new() {
    _pool = new List<BtlEffectData>();
  }
}
