package jp_2dgames.game.btl;

import jp_2dgames.game.item.ItemData;

/**
 * 戦闘コマンド
 **/
enum BtlCmd {
  None; // 無効

  Attack(target:BtlTarget, targetID:Int);              // 通常攻撃
  Skill(skillID:Int, target:BtlTarget, targetID:Int);  // スキル
  Item(item:ItemData, target:BtlTarget, targetID:Int); // アイテム
  Escape;                                              // 逃走
}

/**
 * 戦闘コマンドユーティリティ
 **/
class BtlCmdUtil {
}
