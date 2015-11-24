package jp_2dgames.game.btl.types;

import jp_2dgames.game.actor.Params;

/**
 * バトル終了パラメータ
 **/
class BtlEndResult {

  // バトル終了事由
  public var type:BtlEndType;

  // プレイヤーパラメータ
  public var param:Params;

  /**
   * コンストラクタ
   **/
  public function new() {
    type = BtlEndType.None;
    param = new Params();
  }

  /**
   * パラメータの設定
   **/
  public function setParam(param:Params):Void {
    this.param.copy(param);
  }
}
