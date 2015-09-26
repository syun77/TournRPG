package jp_2dgames.game.btl.logic;

import jp_2dgames.game.item.ItemData;

/**
 * バトル演出種別
 **/
enum BtlLogic {
  None;                  // 無効

  // 開始行動
  BeginAttack;              // 通常攻撃開始
  BeginSkill(id:Int);       // スキル開始
  BeginItem(item:ItemData); // アイテム開始

  // 行動終了
  EndAction;

  Attack;                // 通常攻撃
  Skill(id:Int);         // スキル
  Item(item:ItemData);   // アイテム
  Escape(bSuccess:Bool); // 逃走

  Dead; // 死亡
  BtlEnd(bWin:Bool); // バトル終了
  TurnEnd; // ターン終了
  Sequence; // 連続ダメージ
}
