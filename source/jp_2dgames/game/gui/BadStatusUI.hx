package jp_2dgames.game.gui;
import jp_2dgames.game.actor.BadStatusUtil;
import flixel.FlxSprite;

/**
 * バッドステータスUI
 **/
class BadStatusUI extends FlxSprite {

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(Reg.PATH_BADSTATUS);

    _regist();
  }

  /**
   * アニメーション登録
   **/
  private function _regist():Void {
    animation.add(BadStatusUtil.toString(BadStatus.Dead), [0], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Poison), [1], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Confusion), [2], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Paralyze), [3], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Sleep), [4], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Blind), [5], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Curse), [6], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Weak), [7], 1);
  }
}
