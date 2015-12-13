package jp_2dgames.game.gui;

import jp_2dgames.game.btl.BtlGlobal;
import jp_2dgames.game.field.FieldEffectUtil.FieldEffect;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * バトル情報UI
 **/
class BtlInfoUI extends FlxSpriteGroup {

  // ■定数
  // 地形効果
  static inline var TXT_EFFECT_X:Int = 2;
  static inline var TXT_EFFECT_Y:Int = 2;
  // 経過ターン数
  static inline var TXT_TURN_X:Int = TXT_EFFECT_X + 80;
  static inline var TXT_TURN_Y:Int = TXT_EFFECT_Y;

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
    super();

    // 地形効果
    _txtEffect = new FlxText(TXT_EFFECT_X, TXT_EFFECT_Y);
    _txtEffect.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _txtEffect.setBorderStyle(FlxText.BORDER_SHADOW);
    this.add(_txtEffect);

    // 経過ターン数
    _txtTurn = new FlxText(TXT_TURN_X, TXT_TURN_Y);
    _txtTurn.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    _txtTurn.setBorderStyle(FlxText.BORDER_SHADOW);
    this.add(_txtTurn);

    scrollFactor.set();
  }

  public function _setEffect(eft:FieldEffect):Void {
    _txtEffect.text = '地形効果: ${eft}';
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    var turn:Int = BtlGlobal.getTurn() + 1;
    _txtTurn.text = '${turn}Turn';
  }
}
