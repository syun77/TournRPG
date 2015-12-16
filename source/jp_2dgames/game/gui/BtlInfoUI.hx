package jp_2dgames.game.gui;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.btl.BtlGlobal;
import jp_2dgames.game.field.FieldEffectUtil;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * バトル情報UI
 **/
class BtlInfoUI extends FlxSpriteGroup {

  // ■定数
  static inline var BASE_X:Int = 8;
  static inline var BASE_Y:Int = 52;

  // 経過ターン数
  static inline var TXT_TURN_X:Int = 0;
  static inline var TXT_TURN_Y:Int = 0;
  // 地形効果
  static inline var TXT_EFFECT_X:Int = TXT_TURN_X + 80;
  static inline var TXT_EFFECT_Y:Int = TXT_TURN_Y;

  // ■スタティック
  static var _instance:BtlInfoUI = null;

  // 生成
  public static function create(state:FlxState):Void {
    _instance = new BtlInfoUI();
    state.add(_instance);
  }

  // 破棄
  public static function terminate(state:FlxState):Void {
    state.remove(_instance);
    _instance = FlxDestroyUtil.destroy(_instance);
  }

  // 地形効果を設定
  public static function setEffect(eft:FieldEffect):Void {
    _instance._setEffect(eft);
  }

  // ---------------------------
  // ■メンバ変数
  var _txtEffect:FlxText; // 地形効果
  var _txtTurn:FlxText;   // 経過ターン数

  /**
   * コンストラクタ
   **/
  public function new() {
    super(BASE_X, BASE_Y);

    // 経過ターン数
    _txtTurn = _addText(TXT_TURN_X, TXT_TURN_Y, "");
    _txtTurn.setBorderStyle(FlxText.BORDER_SHADOW);

    // 地形効果
    _txtEffect = new FlxText(TXT_EFFECT_X, TXT_EFFECT_Y);
    _txtEffect.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _txtEffect.setBorderStyle(FlxText.BORDER_SHADOW);
    this.add(_txtEffect);

    scrollFactor.set();

    var px2 = x;
    x -= 128;
    FlxTween.tween(this, {x:px2}, 0.5, {ease:FlxEase.expoOut});
  }

  /**
   * テキスト追加
   **/
  private function _addText(px:Float, py:Float, text:String):FlxText {
    var txt = new FlxText(px, py);
    txt.text = text;
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
   * 地形効果のテキストを設定
   **/
  public function _setEffect(eft:FieldEffect):Void {
    var title = UIMsg.get(UIMsg.FIELD_EFFECT);
    var msg = FieldEffectUtil.toMsg(eft);
    if(msg != "") {
      _txtEffect.text = title + msg;
    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // ターン数更新
    var turn:Int = BtlGlobal.getTurn() + 1;
    _txtTurn.text = '${turn} Turn';
  }
}
