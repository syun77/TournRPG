package jp_2dgames.game.particle;

import flixel.FlxG;
import flixel.util.FlxRandom;
import jp_2dgames.lib.MyMath;
import flixel.FlxState;
import flixel.util.FlxAngle;
import flash.display.BlendMode;
import flixel.util.FlxRandom;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * パーティクルの種類
 **/
enum PType {
  Circle;  // 円
  Circle2; // 円2
  Ring;    // リング
  Ring2;   // リング2
  Ring3;   // リング3(逆再生)
  Hit;     // ヒット
  Blade;   // 斬る
  Bubble;  // ふわふわする玉
}

/**
 * パーティクル
 **/
class Particle extends FlxSprite {

  // パーティクル管理
  public static var parent:FlxTypedGroup<Particle> = null;

  /**
   * 生成
   **/
  public static function create(state:FlxState):Void {
    parent = new FlxTypedGroup<Particle>(256);
    for(i in 0...parent.maxSize) {
      parent.add(new Particle());
    }
    state.add(parent);
  }

  /**
   * 消滅
   **/
  public static function terminate():Void {
    parent = null;
  }

  /**
   * 開始
   **/
  public static function start(type:PType, X:Float, Y:Float, color:Int, bScroll:Bool=true):Void {
    switch(type) {
      case PType.Circle:
        var dir = FlxRandom.floatRanged(0, 45);
        for(i in 0...8) {
          var p:Particle = parent.recycle();
          var spd = FlxRandom.floatRanged(100, 400);
          var t = FlxRandom.intRanged(40, 60);
          p.init(type, t, X, Y, dir, spd, bScroll);
          p.color = color;
          dir += FlxRandom.floatRanged(40, 50);
        }
      case PType.Ring, PType.Ring2, PType.Ring3:
        var t = 60;
        var p:Particle = parent.recycle();
        p.init(type, t, X, Y, 0, 0, bScroll);
        p.color = color;

      case PType.Circle2:
        var p:Particle = parent.recycle();
        var spd = FlxRandom.floatRanged(10, 20);
        var t = FlxRandom.intRanged(40, 60);
        p.init(type, t, X, Y, 90, spd, bScroll);
        p.color = color;

      case PType.Hit:
        // ヒットエフェクト
        var t = 16;
        var p:Particle = parent.recycle();
        p.init(type, t, X, Y, 0, 0, bScroll);
        p.color = color;

      case PType.Blade:
        // 斬る
        for(i in 0...8) {
          var px = X + FlxRandom.intRanged(-32, 32);
          var py = Y + FlxRandom.intRanged(-16, 16);
          var p:Particle = parent.recycle();
          var spd = FlxRandom.floatRanged(10, 20);
          var t = FlxRandom.intRanged(40, 60);
          p.init(type, t, px, py, 90, spd, bScroll);
          p.color = color;
        }

      case PType.Bubble:
        // ふわふわする玉
        var p:Particle = parent.recycle();
        var px = FlxRandom.intRanged(32, FlxG.width-32);
        var py = FlxG.height;
        var spd = FlxRandom.floatRanged(50, 200);
        p.init(type, 1, px, py, 90, spd, bScroll);
        p.color = color;
    }
  }

  // 種別
  private var _type:PType;
  // タイマー
  private var _timer:Int;
  // 開始タイマー
  private var _tStart:Int;
  // 拡張パラメータ
  private var _val:Float;
  // 拡張パラメータ2
  private var _val2:Float;
  // 最初のX座標
  private var _xstart:Float;
  // 最初のY座標
  private var _ystart:Float;

  /**
	 * コンストラクタ
	 **/

  public function new() {
    super();
    loadGraphic(Reg.PATH_EFFECT, true);

    // アニメーション登録
    animation.add('${PType.Circle}', [0], 1);
    animation.add('${PType.Ring}', [1], 2);
    animation.add('${PType.Ring2}', [1], 2);
    animation.add('${PType.Ring3}', [1], 2);
    animation.add('${PType.Circle2}', [0], 1);
    animation.add('${PType.Hit}', [2], 1);
    animation.add('${PType.Blade}', [3], 1);
    animation.add('${PType.Bubble}', [0], 1);

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // 非表示
    kill();
  }

  /**
   * 初期化
   **/
  public function init(type:PType, timer:Int, X:Float, Y:Float, direction:Float, speed:Float, bScroll:Bool):Void {
    _type = type;
    animation.play('${type}');
    _timer = timer;
    _tStart = timer;
    _val = 0;
    _val2 = 0;
    _xstart = X;
    _ystart = Y;

    // 加算ブレンド
    blend = BlendMode.ADD;

    // 座標と速度を設定
    x = X;
    y = Y;
    var rad = FlxAngle.asRadians(direction);
    velocity.x = Math.cos(rad) * speed;
    velocity.y = -Math.sin(rad) * speed;

    // 初期化
    alpha = 1.0;
    switch(_type) {
      case PType.Circle:
        scale.set(0.5, 0.5);
        acceleration.y = 300;
      case PType.Ring, PType.Ring2, PType.Ring3:
        scale.set(0, 0);
        acceleration.y = 0;
      case PType.Circle2:
        scale.set(0.25, 0.25);
        acceleration.y = -200;
        _val = FlxRandom.float() * 3.14*2;
      case PType.Hit:
        scale.set(0.5, 0.5);
      case PType.Blade:
        scale.set(0.5, 0.5);
        acceleration.y = -FlxRandom.intRanged(100, 200);
        angle = 90;
      case PType.Bubble:
        // 通常の半透明
        blend = BlendMode.ALPHA;
        var sc = FlxRandom.floatRanged(0.1, 0.3);
        scale.set(sc, sc);
        _val = FlxRandom.float() * 3.14*2;
        _val2 = 16 + FlxRandom.intRanged(16, 80);
    }

    if(bScroll) {
      scrollFactor.set(1, 1);
    }
    else {
      scrollFactor.set(0, 0);
    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_type) {
      case PType.Circle:
        _timer--;
        velocity.x *= 0.95;
        velocity.y *= 0.95;
        scale.x *= 0.97;
        scale.y *= 0.97;
      case PType.Ring:
        _timer = Std.int(_timer * 0.93);
        var sc = 3 * (_tStart - _timer) / _tStart;
        scale.set(sc, sc);
        alpha = _timer / _tStart;
      case PType.Ring2:
        _timer = Std.int(_timer * 0.93);
        var sc = 2 * (_tStart - _timer) / _tStart;
        scale.set(sc, sc);
        alpha = _timer / _tStart;
      case PType.Ring3:
        _timer = Std.int(_timer * 0.93);
        var sc = 3 * _timer / _tStart;
        scale.set(sc, sc);
        alpha = _timer / _tStart;
      case PType.Circle2:
        _timer--;
        _val += 0.05*2;
        if(_val > 3.14*2) {
          _val -= 3.14*2;
        }

        x = _xstart + 16 * Math.sin(_val);
        velocity.y *= 0.95;
        scale.x *= 0.97;
        scale.y *= 0.97;
      case PType.Hit:
        _timer--;
        var deg = 180 * _timer / _tStart;
        var sc = 0.5 + 1 * MyMath.sinEx(deg);
        scale.set(sc, sc);
        alpha = _timer / _tStart;
      case PType.Blade:
        _timer--;
        scale.y *= 0.9;
        scale.x *= 0.97;
        alpha = _timer / _tStart;
      case PType.Bubble:
        _val += 0.03;
        x = _xstart + _val2 * Math.sin(_val);
        if(y < 0) {
          _timer = 0;
        }
    }

    if(_timer < 1) {
      // 消滅
      kill();
    }
  }
}
