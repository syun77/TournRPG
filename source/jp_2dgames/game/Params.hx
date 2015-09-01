package jp_2dgames.game;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var hp    = 100;
  public var hpmax = 100;

  public function new() {
  }

  public function copy(p:Params):Void {
    hp    = p.hp;
    hpmax = p.hpmax;
  }
}
