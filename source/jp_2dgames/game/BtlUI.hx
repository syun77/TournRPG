package jp_2dgames.game;
import flixel.group.FlxSpriteGroup;

/**
 * バトルUI
 **/
class BtlUI extends FlxSpriteGroup {
  public function new() {
    super();

    // テスト用にボタン配置
    var px = 0;
    var py = 0;
    var btn = new MyButton(px, py, "ATTACK3", function() {
      trace("ATTACK");
    });
    this.add(btn);
    px += 80;
    this.add(new MyButton(px, py, "ATTACK1", function() {
      btn.enabled = true;
    }));
    px += 80;
    this.add(new MyButton(px, py, "ATTACK2", function() {
      btn.enabled = false;
    }));
  }
}
