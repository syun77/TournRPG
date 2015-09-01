package jp_2dgames.game;

/**
 * キャラクター
 **/
class Actor {

  var _param:Params;
  public var param(get, never);
  private function get__param() {
    return _param;
  }

  public function new() {
    param = new Params();
  }

  public function init(params:Params):Void {
    _param.copy(param);
  }
}
