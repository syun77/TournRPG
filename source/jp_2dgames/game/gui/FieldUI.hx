package jp_2dgames.game.gui;

import flixel.util.FlxColor;
import jp_2dgames.game.actor.Actor;
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
  static inline var POS_DX:Int = 32;

  // ■スタティック
  static var _instance:FieldUI = null;

  // 開く
  public static function open(state:FlxState, actor:Actor):Void {
    _instance = new FieldUI(actor);
    state.add(_instance);
  }

  // 閉じる
  public static function close(state:FlxState):Void {
    state.remove(_instance);
    _instance = FlxDestroyUtil.destroy(_instance);
  }

  // ■メンバ変数
  // テキスト
  var _actor:Actor;
  var _txtFloor:FlxText;
  var _txtMoney:FlxText;
  var _txtFood:FlxText;

  var _tAnim:Int = 0; // アニメタイマー

  /**
   * コンストラクタ
   **/
  public function new(actor:Actor) {
    super(BASE_X, BASE_Y);
    _actor = actor;

    // フロア数テキスト
    var px:Int = 0;
    var py:Int = 0;
    _txtFloor = _addText(px, py, '${Global.getFloor()}F');

    // 所持金テキスト
    px += Std.int(POS_DX*1.5);
    _txtMoney = new FlxText(px, py);
    _txtMoney.setBorderStyle(FlxText.BORDER_SHADOW);
    this.add(_txtMoney);

    // 所持金アイコン
    var money = new FlxSprite(px-24, py-10, Reg.PATH_FIELD_MONEY);
    money.scale.set(0.5, 0.5);
    this.add(money);

    // 食糧テキスト
    px += Std.int(POS_DX * 1.75);
    _txtFood = new FlxText(px, py);
    _txtFood.setBorderStyle(FlxText.BORDER_SHADOW);
    this.add(_txtFood);

    // 食糧アイコン
    var food = new FlxSprite(px-24, py-11, Reg.PATH_FIELD_FOOD);
    food.scale.set(0.75, 0.75);
    this.add(food);

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

    _tAnim++;

    _txtMoney.text = '${Global.getMoney()}G';
    var food = _actor.food;
    _txtFood.text = 'x ${food}';
    _txtFood.color = FlxColor.WHITE;
    if(food <= 3 && _tAnim%32 < 16) {
      _txtFood.color = FlxColor.CRIMSON;
    }
  }
}
