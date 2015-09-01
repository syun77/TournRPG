package jp_2dgames.game;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var id    = 0;   // ID
  public var hp    = 100; // HP
  public var hpmax = 100; // 最大HP

  public function new() {
  }

  public function copy(p:Params):Void {
    id    = p.id;
    hp    = p.hp;
    hpmax = p.hpmax;
  }
}
