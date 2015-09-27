package jp_2dgames.game.particle;

import jp_2dgames.lib.SprFont;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
  Main;  // メイン
  Fade;  // フェードで消える
}

/**
 * ダメージエフェクト
 **/
class ParticleDamage extends FlxSprite {

  // フォントサイズ
  private static inline var FONT_SIZE:Int = 16;

  // ■速度関連
  // 開始速度
  private static inline var SPEED_Y_INIT:Float = -20;

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
  // ミス用の演出かどうか
  private var _bMiss:Bool;

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

    var w = 0;
    if(val >= 0) {
      // 数値フォントを描画する
      w = SprFont.render(this, '${val}');
      _timer = 32;
    }
    else {
      // 攻撃が外れた
      w = SprFont.render(this, 'MISS!');
      _timer = 16;
    }
    // 移動開始
    velocity.y = SPEED_Y_INIT;
    _bMiss = true;

    // フォントを中央揃えする
    x = X - (w / 2);

    visible = true;
    alpha = 1;

    // スクロール有効
    scrollFactor.set(1, 1);

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
        _timer--;
        if(_timer == 0) {
          // フェードで消える
          _state = State.Fade;
        }

      case State.Fade:
        // フェードで消える
        alpha -= 1.0 / 8;
        if(alpha < 0) {
          kill();
        }
    }

  }
}
