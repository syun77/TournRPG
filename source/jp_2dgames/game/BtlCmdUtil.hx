package jp_2dgames.game;

/**
 * 戦闘コマンド
 **/
enum BtlCmd {
  None;           // 無効

  Attack(id:Int); // 通常攻撃
  Skill(id:Int);  // スキル
  Item(id:Int);   // アイテム
  Escape;         // 逃走
}

/**
 * 戦闘コマンドユーティリティ
 **/
class BtlCmdUtil {
}
