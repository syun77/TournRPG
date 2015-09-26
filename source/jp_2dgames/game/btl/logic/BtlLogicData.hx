package jp_2dgames.game.btl.logic;

import jp_2dgames.game.btl.BtlGroupUtil;

/**
 * バトル演出情報
 **/
class BtlLogicData {
  public var actorID:Int     = 0;                  // 行動主体者
  public var group:BtlGroup  = BtlGroup.Player;    // 所属グループ
  public var type:BtlLogic   = BtlLogic.None;      // 演出種別
  public var targetID:Int    = 0;                  // 対象者
  public var bWaitQuick:Bool = false;              // 完了待ちを短縮するかどうか

  /**
   * コンストラクタ
   * @param actorID 行動主体者
   * @param group   所属グループ
   * @param type    実行種別
   **/
  public function new(actorID:Int, group:BtlGroup, type:BtlLogic) {
    this.actorID = actorID;
    this.group   = group;
    this.type    = type;
  }

  /**
   * コピーする
   **/
  public function copy(src:BtlLogicData):Void {
    actorID  = src.actorID;
    group    = src.group;
    type     = src.type;
    targetID = src.targetID;
  }

  /**
   * 対象者を設定
   **/
  public function setTarget(targetID:Int):Void {
    this.targetID = targetID;
  }
}
