package jp_2dgames.game.actor;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var id:Int    = 1;   // ID
  public var lv:Int    = 1;   // レベル
  public var hp:Int    = 100; // HP
  public var hpmax:Int = 100; // 最大HP
  public var mp:Int    = 30;  // MP
  public var mpmax:Int = 30;  // 最大MP
  public var str:Int   = 5;   // 力
  public var vit:Int   = 5;   // 耐久力
  public var agi:Int   = 5;   // 素早さ
  public var xp:Int    = 10;  // 経験値
  public var money:Int = 100; // 所持金

  public function new() {
  }

  public function copy(p:Dynamic):Void {
    id    = p.id;
    lv    = p.lv;
    hp    = p.hp;
    hpmax = p.hpmax;
    mp    = p.mp;
    mpmax = p.mpmax;
    str   = p.str;
    vit   = p.vit;
    agi   = p.agi;
    xp    = p.xp;
    money = p.money;
  }
}
