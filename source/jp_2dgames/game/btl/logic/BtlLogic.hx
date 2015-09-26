package jp_2dgames.game.btl.logic;

import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
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

  HpDamage(val:Int, bSeq:Bool); // HPダメージ
  ChanceRoll(b:Bool);           // 成功 or 失敗
  Badstatus(bst:BadStatus);     // バッドステータス


  Item(item:ItemData);   // アイテム
  Escape(bSuccess:Bool); // 逃走

  Dead; // 死亡
  BtlEnd(bWin:Bool); // バトル終了
}

/**
 * バトル演出種別ユーティリティ
 **/
class BtlLogicUtil {

  /**
   * 開始演出かどうか
   **/
  public static function isBegin(type:BtlLogic):Bool {
    switch(type) {
      case BtlLogic.BeginAttack, BtlLogic.BeginSkill, BtlLogic.BeginItem:
        return true;
      default:
        return false;
    }
  }
}
