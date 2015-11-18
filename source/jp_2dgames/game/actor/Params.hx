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
  public var food:Int  = 0;   // 満腹度
  public var buffAtk:Int = 0; // バフ・攻撃力 (マイナスはデバフ)
  public var buffDef:Int = 0; // バフ・守備力 (マイナスはデバフ)
  public var buffSpd:Int = 0; // バフ・命中率 (マイナスはデバフ)

  public function new() {
  }

  /**
   * コピー
   **/
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
    food  = p.food;

    buffAtk = p.buffAtk;
    buffDef = p.buffDef;
    buffSpd = p.buffSpd;
  }

  /**
   * バフ・デバグを初期化する
   **/
  public function resetBuf():Void {
    buffAtk = 0;
    buffDef = 0;
    buffSpd = 0;
  }
}
