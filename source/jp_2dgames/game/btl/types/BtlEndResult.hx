package jp_2dgames.game.btl.types;

import jp_2dgames.game.actor.PartyMgr;

/**
 * バトル終了パラメータ
 **/
class BtlEndResult {

  // バトル終了事由
  public var type:BtlEndType;

  // パーティ情報
  public var party:PartyMgr;

  /**
   * コンストラクタ
   **/
  public function new() {
    type = BtlEndType.None;
    party = new PartyMgr();
  }
}
