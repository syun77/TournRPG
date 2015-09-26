package jp_2dgames.game.skill;

/**
 * スキル効果範囲
 **/
enum SkillRange {
  Self;      // 自分自身
  FriendOne; // 味方・単体
  FriendAll; // 味方・グループ
  EnemyOne;  // 敵・単体
  EnemyAll;  // 敵・グループ
  All;       // すべて
}