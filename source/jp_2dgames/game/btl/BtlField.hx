package jp_2dgames.game.btl;

import jp_2dgames.game.field.FieldEffectUtil;

/**
 * バトルの地形情報
 **/
class BtlField {

  // シングルトン
  private static var _instance:BtlField = null;

  public static function create(eft:FieldEffect):Void {
    _instance = new BtlField(eft);
  }
  public static function destroy():Void {
    _instance = null;
  }

  public static function getEffect():FieldEffect {
    return _instance._eft;
  }

  // 地形効果
  private var _eft:FieldEffect;

  /**
   * コンストラクタ
   **/
  public function new(eft:FieldEffect) {
    _eft = eft;
  }

}
