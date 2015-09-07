package jp_2dgames.game.btl;

import jp_2dgames.game.item.ItemData;

/**
 * 戦闘コマンド
 **/
enum BtlCmd {
  None; // 無効

  Attack(range:BtlRange, targetID:Int);              // 通常攻撃
  Skill(skillID:Int, range:BtlRange, targetID:Int);  // スキル
  Item(item:ItemData, range:BtlRange, targetID:Int); // アイテム
  Escape;                                            // 逃走
}

/**
 * 戦闘コマンドユーティリティ
 **/
class BtlCmdUtil {
}
