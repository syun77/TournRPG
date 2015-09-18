package jp_2dgames.game.skill;

/**
 * スキル種別
 **/
enum SkillType {

  None; // 無効

  // 攻撃スキル
  AtkPhyscal;   // 物理攻撃
  AtkMagical;   // 魔法攻撃
  AtkBadstatus; // バステ攻撃

  // 回復・補助
  Recover;      // 回復
  Buff;         // 補助

  // 自動
  Auto;         // 自動発動
  AutoAttr;     // 耐性アップ
  AutoStatusUp; // ステータス上昇
}
