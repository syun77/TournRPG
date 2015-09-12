package jp_2dgames.game.particle;

import flixel.FlxState;
import flash.geom.Rectangle;
import flash.geom.Point;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
  Main;  // メイン
  Wait;  // ちょっと待つ
  Blink; // 点滅
}

/**
 * ダメージエフェクト
 **/
class ParticleDamage extends FlxSprite {

  // フォントサイズ
  private static inline var FONT_SIZE:Int = 16;

  // ■速度関連
  // 開始速度
  private static inline var SPEED_Y_INIT:Float = -200;
  // 重力加速度
  private static inline var GRAVITY:Float = 15;
  // 床との反発係数
  private static inline var FRICTION:Float = 0.5;

  // パーティクル管理
  public static var parent:FlxTypedGroup<ParticleDamage> = null;
  /**
   * 生成
   **/
  public static function create(state:FlxState):Void {
    parent = new FlxTypedGroup<ParticleDamage>(16);
    for(i in 0...parent.maxSize) {
      parent.add(new ParticleDamage());
    }
    state.add(parent);
  }
  /**
   * 破棄
   **/
  public static function terminate():Void {
    parent = null;
  }

  public static function start(X:Float, Y:Float, val:Int):ParticleDamage{
    var p:ParticleDamage = parent.recycle();
    p.init(X, Y, val);
    return p;
  }

  // 開始座標
  private var _ystart:Float;
  private var _state:State;
  private var _timer:Int;

  /**
	 * コンストラクタ
	 **/

  public function new() {
    super();

    makeGraphic(FONT_SIZE * 8, FONT_SIZE, FlxColor.TRANSPARENT, true);

    // 非表示にしておく
    kill();
  }

  /**
	 * 初期化
	 **/

  public function init(X:Float, Y:Float, val:Int) {
    x = X;
    y = Y;
    _ystart = Y;

    // 描画をクリアする
    pixels.fillRect(new Rectangle(0, 0, FONT_SIZE * 8, FONT_SIZE), FlxColor.TRANSPARENT);

    // フォント画像読み込み
    var bmp = FlxG.bitmap.add(Reg.PATH_SPR_FONT);
    var pt = new Point();
    var rect = new Rectangle(0, 0, FONT_SIZE, FONT_SIZE);
    // 数字の桁数を求める
    var digit = Std.string(val).length;
    for(i in 0...digit) {
      // フォントをレンダリングする
      pt.x = (digit - i - 1) * FONT_SIZE;
      var v = Std.int(val / Math.pow(10, i)) % 10;
      rect.left = v * FONT_SIZE;
      rect.right = rect.left + FONT_SIZE;
      pixels.copyPixels(bmp.bitmap, rect, pt);
    }
    dirty = true;
    updateFrameData();

    // フォントを中央揃えする
    x = X - (FONT_SIZE * digit / 2);

    // 移動開始
    velocity.y = SPEED_Y_INIT;

    visible = true;

    // メイン状態へ
    _state = State.Main;
  }

  /**
	 * コンストラクタ
	 **/

  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Main:
        // 落下中
        velocity.y += GRAVITY;
        if(y > _ystart) {
          // 出現位置より下に下がった
          y = _ystart;
          // バウンドする
          velocity.y *= -FRICTION;
          if(Math.abs(velocity.y) < 30) {
            // 一定速度以下でバウンド終了
            velocity.y = 0;
            _timer = 30;
            _state = State.Wait;
          }
        }
      case State.Wait:
        // ちょっと待つ
        _timer--;
        if(_timer < 1) {
          _timer = 15;
          _state = State.Blink;
        }
      case State.Blink:
        // 点滅して消える
        visible = (_timer % 4 >= 2);
        _timer--;
        if(_timer < 1) {
          kill();
        }
    }

  }
}
