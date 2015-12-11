package jp_2dgames.game.field;
import flixel.util.FlxAngle;
import flash.display.BlendMode;
import flixel.util.FlxRandom;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * パーティクルの種類
 **/
enum FieldParticleType {
  Spiral; // らせん
}

/**
 * フィールドのパーティクル
 **/
class FieldParticle extends FlxSprite {

  // パーティクル管理
  public static var parent:FlxTypedGroup<FieldParticle> = null;

  /**
   * 生成
   **/
  public static function create(state:FlxState):Void {
    parent = new FlxTypedGroup<FieldParticle>(256);
    for(i in 0...parent.maxSize) {
      parent.add(new FieldParticle());
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
  public static function start(Type:FieldParticleType, X:Float, Y:Float, color:Int):Void {
    switch(Type) {
      case FieldParticleType.Spiral:
        var p:FieldParticle = parent.recycle();
        var spd = FlxRandom.floatRanged(10, 20);
        var t = FlxRandom.intRanged(40, 60);
        p.init(Type, t, X, Y, 90, spd);
        p.color = color;
    }
  }

  // ====================================================
  // ■メンバ変数定義
  // 種別
  private var _type:FieldParticleType;
  // タイマー
  private var _timer:Int;
  // 開始タイマー
  private var _tStart:Int;
  // 拡張パラメータ
  private var _val:Float;
  // 最初のX座標
  private var _xprev:Float;

  /**
   * コンストラクタ
   **/
  public function new() {

    super();
    loadGraphic(Reg.PATH_EFFECT, true);

    // アニメーション登録
    animation.add('${FieldParticleType.Spiral}', [0], 1);
//    animation.add('${PType.Circle}', [0], 1);
//    animation.add('${PType.Ring}', [1], 2);
//    animation.add('${PType.Ring2}', [1], 2);
//    animation.add('${PType.Ring3}', [1], 2);
//    animation.add('${PType.Circle2}', [0], 1);
//    animation.add('${PType.Hit}', [2], 1);
//    animation.add('${PType.Blade}', [3], 1);

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // 非表示
    kill();
  }

  /**
   * 初期化
   **/
  public function init(type:FieldParticleType, timer:Int, X:Float, Y:Float, direction:Float, speed:Float):Void {
    _type = type;
    animation.play('${type}');
    _timer = timer;
    _tStart = timer;
    _val = 0;
    _xprev = X;

    // 座標と速度を設定
    x = X;
    y = Y;
    var rad = FlxAngle.asRadians(direction);
    velocity.x = Math.cos(rad) * speed;
    velocity.y = -Math.sin(rad) * speed;

    // 初期化
    alpha = 1.0;
    switch(_type) {
      case FieldParticleType.Spiral:
        scale.set(0.25, 0.25);
        acceleration.y = -200;
        _val = FlxRandom.float() * 3.14*2;
    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_type) {
      case FieldParticleType.Spiral:
        _timer--;
        _val += 0.05*2;
        if(_val > 3.14*2) {
          _val -= 3.14*2;
        }

        x = _xprev + 16 * Math.sin(_val);
        velocity.y *= 0.95;
        scale.x *= 0.97;
        scale.y *= 0.97;
    }

    if(_timer < 1) {
      // 消滅
      kill();
    }
  }
}
