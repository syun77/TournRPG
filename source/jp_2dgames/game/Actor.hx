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
  public var param(get, never):Params;
  private function get_param() {
    return _param;
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
}
