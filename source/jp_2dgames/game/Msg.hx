package jp_2dgames.game;
class Msg {
  public static inline var DAMAGE_PLAYER:Int = 1; // プレイヤーへのダメージ
  public static inline var DAMAGE_ENEMY:Int  = 2; // 敵へのダメージ
  public static inline var ATTACK_BEGIN:Int  = 3; // 攻撃開始
  public static inline var DEFEAT_ENEMY:Int  = 4; // 敵を倒した
  public static inline var BATTLE_WIN:Int    = 5; // 戦闘に勝利した
  public static inline var BATTLE_LOSE:Int   = 6; // 戦闘に負けた
  public static inline var ITEM_USE:Int      = 7; // アイテムを使った
  public static inline var RECOVER_HP:Int    = 8; // HP回復
  public static inline var ESCAPE:Int        = 9; // 逃走開始
}
