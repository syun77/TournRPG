package jp_2dgames.game;

/**
 * バトル管理
 **/
class BtlMgr {

  var _player:Actor;
  var _enemy:Actor;

  /**
   * コンストラクタ
   **/
  public function new() {
    _player = Actor.add();
    _enemy = Actor.add();
  }

  /**
   * 更新
   **/
  public function proc():Void {

  }
}
