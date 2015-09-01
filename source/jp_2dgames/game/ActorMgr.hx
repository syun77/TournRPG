package jp_2dgames.game;

import jp_2dgames.game.PartyGroupUtil;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * キャラクター管理
 **/
class ActorMgr extends FlxTypedGroup<Actor> {
  static var _instance:ActorMgr = null;

  /**
   * 生成
   **/
  public static function create(state:FlxState) {
    if(_instance == null) {
      _instance = new ActorMgr(state);
    }
  }

  /**
   * 末期化
   **/
  public static function terminate() {
    _instance = null;
  }

  /**
   * インスタンスを新規に取得
   **/
  public static function recycleActor(group:PartyGroup, param:Params):Actor {
    var actor:Actor = _instance.recycle();
    actor.init(group, param);
    return actor;
  }

  /**
   * 指定したIDに一致するインスタンスを取得
   **/
  public static function search(id:Int):Actor {
    var ret:Actor = null;
    _instance.forEachAlive(function(actor:Actor) {
      if(id == actor.ID) {
        ret = actor;
      }
    });

    return ret;
  }

  /**
   * 生存しているActorのリストを取得
   **/
  public static function getAlive():Array<Actor> {
    var ret = new Array<Actor>();
    _instance.forEachAlive(function(actor:Actor) {
      ret.push(actor);
    });
    return ret;
  }

  /**
   * コンストラクタ
   **/
  public function new(state:FlxState) {
    // 16体作る
    super(16);
    for(i in 0...maxSize) {
      this.add(new Actor(i));
    }

    state.add(this);
  }
}
