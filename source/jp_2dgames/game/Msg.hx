package jp_2dgames.game;
class Msg {
  public static inline var DAMAGE_PLAYER:Int  = 1;  // プレイヤーへのダメージ
  public static inline var DAMAGE_ENEMY:Int   = 2;  // 敵へのダメージ
  public static inline var ATTACK_BEGIN:Int   = 3;  // 攻撃開始
  public static inline var DEFEAT_ENEMY:Int   = 4;  // 敵を倒した
  public static inline var BATTLE_WIN:Int     = 5;  // 戦闘に勝利した
  public static inline var BATTLE_LOSE:Int    = 6;  // 戦闘に負けた
  public static inline var ITEM_USE:Int       = 7;  // アイテムを使った
  public static inline var RECOVER_HP:Int     = 8;  // HP回復
  public static inline var ESCAPE:Int         = 9;  // 逃走開始
  public static inline var ITEM_DROP:Int      = 10; // アイテムを落とした
  public static inline var ITEM_GET:Int       = 11; // アイテム入手
  public static inline var ITEM_CANT_GET:Int  = 12; // アイテムを入手できない
  public static inline var ITEM_DEL_GET:Int   = 13; // アイテムを捨てて拾う
  public static inline var ITEM_ABANDAN:Int   = 14; // アイテムをあきらめる
  public static inline var ITEM_SEL_DEL:Int   = 15; // 捨てるアイテムを選択
  public static inline var XP_GET:Int         = 16; // 経験値を獲得
  public static inline var LEVELUP:Int        = 17; // レベルアップ
  public static inline var RECOVER_HP_ALL:Int = 18; // HP全回復
  public static inline var SKILL_BEGIN:Int    = 19; // スキル発動
  public static inline var ATTACK_MISS:Int    = 20; // 攻撃回避
  public static inline var SKILL_MISS:Int     = 21; // スキル回避
}
