package jp_2dgames.game.btl.logic;

import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.btl.types.BtlCmd;
import jp_2dgames.game.btl.BtlGroupUtil;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;

/**
 * バトル発生効果値
 **/
enum BtlLogicVal {
  HpDamage(val:Int);        // HPダメージ
  HpRecover(val:Int);       // HP回復
  ChanceRoll(b:Bool);       // 成功or失敗
  Badstatus(bst:BadStatus); // バステ付着
}

/**
 * バトル演出情報
 **/
class BtlLogicData {
  public var actorID:Int     = 0;                  // 行動主体者
  public var group:BtlGroup  = BtlGroup.Player;    // 所属グループ
  public var cmd:BtlCmd      = BtlCmd.None;        // コマンド種別
  public var target:BtlRange = BtlRange.One;       // 対象種別
  public var targetID:Int    = 0;                  // 対象者
  public var vals:List<BtlLogicVal>;               // 効果値

  /**
   * コンストラクタ
   * @param actorID 行動主体者
   * @param group   所属グループ
   * @param cmd     実行コマンド
   **/
  public function new(actorID:Int, group:BtlGroup, cmd:BtlCmd) {
    this.actorID = actorID;
    this.group   = group;
    this.cmd     = cmd;
    vals = new List<BtlLogicVal>();
  }

  /**
   * コピーする
   **/
  public function copy(src:BtlLogicData):Void {
    actorID  = src.actorID;
    group    = src.group;
    cmd      = src.cmd;
    target   = src.target;
    targetID = src.targetID;
    vals      = src.vals;
  }

  /**
   * 対象者を設定
   **/
  public function setTarget(target:BtlRange, targetID:Int):Void {
    this.target   = target;
    this.targetID = targetID;
  }
}
