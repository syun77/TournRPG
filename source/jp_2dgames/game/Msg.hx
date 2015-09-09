package jp_2dgames.game;
class Msg {
  public static inline var DAMAGE_PLAYER:Int = 1;  // プレイヤーへのダメージ
  public static inline var DAMAGE_ENEMY:Int  = 2;  // 敵へのダメージ
  public static inline var ATTACK_BEGIN:Int  = 3;  // 攻撃開始
  public static inline var DEFEAT_ENEMY:Int  = 4;  // 敵を倒した
  public static inline var BATTLE_WIN:Int    = 5;  // 戦闘に勝利した
  public static inline var BATTLE_LOSE:Int   = 6;  // 戦闘に負けた
  public static inline var ITEM_USE:Int      = 7;  // アイテムを使った
  public static inline var RECOVER_HP:Int    = 8;  // HP回復
  public static inline var ESCAPE:Int        = 9;  // 逃走開始
  public static inline var ITEM_DROP:Int     = 10; // アイテムを落とした
  public static inline var ITEM_GET:Int      = 11; // アイテム入手
  public static inline var ITEM_CANT_GET:Int = 12; // アイテムを入手できない
  public static inline var ITEM_DEL_GET:Int  = 13; // アイテムを捨てて拾う
  public static inline var ITEM_ABANDAN:Int  = 14; // アイテムをあきらめる

}
