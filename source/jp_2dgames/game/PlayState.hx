package jp_2dgames.game;

import flixel.group.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム
 */
class PlayState extends FlxState {

  // バトル管理
  var _btlMgr:BtlMgr;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    Actor.parent = new FlxTypedGroup<Actor>(16);
    for(i in 0...Actor.parent.maxSize) {
      Actor.parent.add(new Actor(i));
    }
    this.add(Actor.parent);

    // UI登録
    this.add(new BtlUI());

    // バトル管理生成
    _btlMgr = new BtlMgr();
  }

  /**
   * 破棄
   */
  override public function destroy():Void {
    Actor.parent = null;

    super.destroy();
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();

    _btlMgr.proc();

    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
  }
}