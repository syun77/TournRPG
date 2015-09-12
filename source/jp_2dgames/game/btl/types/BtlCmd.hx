package jp_2dgames.game.btl.types;

import jp_2dgames.game.item.ItemData;

/**
 * 戦闘コマンド
 **/
enum BtlCmd {
  None; // 無効

  Attack(range:BtlRange, targetID:Int);              // 通常攻撃
  Skill(skillID:Int, range:BtlRange, targetID:Int);  // スキル
  Item(item:ItemData, range:BtlRange, targetID:Int); // アイテム
  Escape(bSuccess:Bool);                             // 逃走

  // 演出用
  Dead;              // 死亡
  BtlEnd(bWin:Bool); // バトル勝利
}
