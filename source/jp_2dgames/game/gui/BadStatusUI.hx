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
    loadGraphic(Reg.PATH_BADSTATUS, true);

    _regist();
  }

  /**
   * アニメーション登録
   **/
  private function _regist():Void {
    animation.add(BadStatusUtil.toString(BadStatus.Dead), [0], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Poison), [1], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Confusion), [2], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Close), [3], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Paralyze), [4], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Sleep), [5], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Blind), [6], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Curse), [7], 1);
    animation.add(BadStatusUtil.toString(BadStatus.Weak), [8], 1);
  }

  public function set(bst:BadStatus):Void {
    if(bst == BadStatus.None) {
      // 正常なので表示しない
      visible = false;
    }
    else {
      // バステアイコン表示
      visible = true;
      animation.play(BadStatusUtil.toString(bst));
    }
  }
}
