package jp_2dgames.game;

import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * キャラクター
 **/
class Actor extends FlxSprite {

  // 親
  public static var parent:FlxTypedGroup<Actor> = null;
  public static function add():Actor {
    var actor:Actor = parent.recycle();
    return actor;
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

    ID = id;
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
