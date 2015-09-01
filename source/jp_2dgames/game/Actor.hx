package jp_2dgames.game;

import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * キャラクター
 **/
class Actor extends FlxSprite {

  // 親
  public static var parent:FlxTypedGroup<Actor> = null;
  /**
   * インスタンスを新規に取得
   **/
  public static function add():Actor {
    var actor:Actor = parent.recycle();
    return actor;
  }

  /**
   * 指定したIDに一致するインスタンスを取得
   **/
  public static function get(id:Int):Actor {
    var ret:Actor = null;
    parent.forEachAlive(function(actor:Actor) {
      if(id == actor.ID) {
        ret = actor;
      }
    });

    return ret;
  }

  var _param:Params;
  public var hp(get, never):Int;
  private function get_hp() {
    return _param.hp;
  }
  public var hpmax(get, never):Int;
  private function get_hpmax() {
    return _param.hpmax;
  }
  public var hpratio(get, never):Float;
  private function get_hpratio() {
    return _param.hp / _param.hpmax;
  }

  /**
   * HPが最大値・最小値を超えないように丸める
   **/
  private function _clampHp():Void {
    if(hp < 0) {
      _param.hp = 0;
    }
    if(hp > hpmax) {
      _param.hp = hpmax;
    }
  }

  /**
   * 死亡したかどうか
   **/
  public function isDead():Bool {
    return hp <= 0;
  }

  /**
   * コンストラクタ
   **/
  public function new(id:Int) {
    super();

    ID = id + 1000;
    _param = new Params();

    // 非表示にしておく
    kill();
    visible = false;
  }

  /**
   * 初期化
   **/
  public function init(params:Params):Void {
    _param.copy(params);
  }

  /**
   * ダメージを与える
   **/
  public function damage(v:Int):Bool {
    _param.hp -= v;
    _clampHp();

    return isDead();
  }
}
