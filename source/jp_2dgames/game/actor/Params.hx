package jp_2dgames.game.actor;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var exists:Bool = false; // 生存フラグ
  public var name:String = "";    // 名前
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

  // バトル開始時に初期化
  public var buffAtk:Int = 0; // バフ・攻撃力 (マイナスはデバフ)
  public var buffDef:Int = 0; // バフ・守備力 (マイナスはデバフ)
  public var buffSpd:Int = 0; // バフ・命中率 (マイナスはデバフ)
  public var bAutoRevive:Bool = false; // 自動復活したかどうか

  public function new() {
  }

  /**
   * コピー
   **/
  public function copy(p:Dynamic):Void {
    exists= p.exists;
    name  = p.name;
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
    bAutoRevive = p.bAutoRevive;
  }

  /**
   * バトルのみ有効なパラメータを初期化
   **/
  public function resetBattle():Void {
    buffAtk = 0;
    buffDef = 0;
    buffSpd = 0;
    bAutoRevive = false;
  }
}
