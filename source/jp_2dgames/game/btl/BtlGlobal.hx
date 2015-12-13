package jp_2dgames.game.btl;

import jp_2dgames.game.field.FieldEffectUtil.FieldEffect;

/**
 * バトル用のグローバル
 **/
class BtlGlobal {

  /**
   * 初期化
   **/
  public static function init(eft:FieldEffect):Void {
    _eft = eft;
  }

  // 経過ターン数
  private static var _turn:Int;
  public static function getTurn():Int {
    return _turn;
  }
  // ターンを進める
  public static function nextTurn():Void {
    _turn++;
  }

  // 地形効果
  private static var _eft:FieldEffect;
  public static function getFieldEffect():FieldEffect {
    return _eft;
  }
}
