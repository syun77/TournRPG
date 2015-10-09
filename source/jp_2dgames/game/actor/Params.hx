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
  public var mag:Int   = 5;   // 魔力
  public var xp:Int    = 0;   // 経験値
  public var money:Int = 0;   // 所持金
  public var buffAtk:Int = 0; // バフ・攻撃力
  public var buffDef:Int = 0; // バフ・守備力
  public var buffHit:Int = 0; // バフ・命中率
  public var debuffAtk:Int = 0; // デバフ・攻撃力
  public var debuffDef:Int = 0; // デバフ・守備力
  public var debuffHit:Int = 0; // デバフ・命中率

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
    mag   = p.mag;
    xp    = p.xp;
    money = p.money;

    buffAtk = p.buffAtk;
    buffDef = p.buffDef;
    buffHit = p.buffHit;
    debuffAtk = p.debuffAtk;
    debuffDef = p.debuffDef;
    debuffHit = p.debuffHit;
  }
}
