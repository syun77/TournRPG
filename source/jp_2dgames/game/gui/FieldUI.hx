package jp_2dgames.game.gui;

import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * フィールドUI
 **/
class FieldUI extends FlxSpriteGroup {

  // ■定数
  static inline var BASE_X:Int = 8;
  static inline var BASE_Y:Int = 52;
  static inline var POS_DY:Int = 16;
  static inline var POS_DX:Int = 48;

  // ■スタティック
  static var _instance:FieldUI = null;

  // 開く
  public static function open(state:FlxState):Void {
    _instance = new FieldUI();
    state.add(_instance);
  }

  // 閉じる
  public static function close(state:FlxState):Void {
    state.remove(_instance);
    _instance = FlxDestroyUtil.destroy(_instance);
  }

  // ■メンバ変数
  var _txtFloor:FlxText;
  var _txtMoney:FlxText;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(BASE_X, BASE_Y);

    var px:Int = 0;
    var py:Int = 0;
    _txtFloor = _addText(px, py, 'Floor: ${Global.getFloor()}');

    px += POS_DX;
    _txtMoney = new FlxText(px, py);
    _txtMoney.setBorderStyle(FlxText.BORDER_SHADOW);
    this.add(_txtMoney);

    var px2 = x;
    x -= 128;
    FlxTween.tween(this, {x:px2}, 0.5, {ease:FlxEase.expoOut});
  }

  private function _addText(px:Float, py:Float, text:String):FlxText {
    var txt = new FlxText(px, py, 48);
    txt.text = text;
    txt.setBorderStyle(FlxText.BORDER_SHADOW);
    var bg = new FlxSprite(px-32, py+2, Reg.PATH_MSG_TEXT);
    bg.scale.x = 0.8;
    bg.scale.y = 1.3;
    bg.x -= bg.width*0.6/2;
    bg.color = MyColor.ASE_NAVY;
    this.add(bg);
    this.add(txt);

    return txt;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _txtMoney.text = '${Global.getMoney()}G';
  }
}
