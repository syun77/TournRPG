package jp_2dgames.game.gui;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * バトルUI
 **/
class BtlUI extends FlxSpriteGroup {

  // ■定数
  static inline var PLAYER_X:Int = 4;
  static inline var PLAYER_Y:Int = 4;
  static inline var PLAYER_DY:Int = 12;

  // ■メンバ変数
  var _charaUIList:Array<BtlCharaUI>;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _charaUIList = new Array<BtlCharaUI>();

    for(i in 0...1) {
      var px = FlxG.width/3 * i;
      var ui = new BtlCharaUI(px, 4);
      _charaUIList.push(ui);
      this.add(ui);
    }
  }

  public function setPlayerID(idx:Int, actorID:Int) {
    _charaUIList[idx].setActorID(actorID);
  }

  override public function update():Void {
    super.update();
  }
}
