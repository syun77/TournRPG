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
  public function new(btlUI:BtlUI) {
    _player = Actor.add();
    _enemy = Actor.add();

    btlUI.setPlayerID(_player.ID);
    btlUI.setEnemyID(_enemy.ID);
  }

  /**
   * 更新
   **/
  public function proc():Void {

  }
}
