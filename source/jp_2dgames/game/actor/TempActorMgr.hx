package jp_2dgames.game.actor;

import flixel.util.FlxRandom;
import jp_2dgames.game.btl.BtlGroupUtil;
import flixel.group.FlxTypedGroup;

/**
 * キャラクター管理のテンポラリ
 **/
class TempActorMgr {
  // 生成インスタンス数
  static inline var MAX = ActorMgr.MAX;

  static var _pool:ActorPool;

  /**
   * ActorMgrから情報をコピーする
   **/
  public static function copyFromActorMgr() {

    // Actor情報をコピー
    _pool = new ActorPool(null, ActorMgr.MAX);
    ActorMgr.forEachAlive(function(actor:Actor) {
      var act = _pool.recycle(actor.group, actor.param);
      act.copy(actor);
    });

    // 墓場情報もコピー
    ActorMgr.forEachGrave(function(actor:Actor) {
      var act = new Actor(0);
      act.copy(actor);
      moveGrave(act);
    });
  }

  /**
   * 破棄
   **/
  public static function destroy() {
    _pool = null;
  }

  /**
   * 指定したIDに一致するインスタンスを取得
   **/
  public static function search(id:Int):Actor {
    return _pool.search(id);
  }

  /**
   * 生存しているActorのリストを取得
   **/
  public static function getAlive():Array<Actor> {
    return _pool.getAlive();
  }

  /**
   * 生存しているActorをすべて実行
   **/
  public static function forEachAlive(func:Actor->Void):Void {
    _pool.forEachAlive(func);
  }

  /**
   * 生存している指定のグループをすべて実行
   **/
  public static function forEachAliveGroup(group:BtlGroup, func:Actor->Void):Void {
    _pool.forEachAliveGroup(group, func);
  }

  /**
   * 指定のグループからランダムに取得する
   **/
  public static function random(group:BtlGroup):Actor {
    return _pool.random(group);
  }

  /**
   * 死亡しているActorを探す
   **/
  public static function searchDead():Actor {
    return _pool.searchDead();
  }

  /**
   * 死亡しているActorをランダムで探す
   **/
  public static function searchGraveRandom(group:BtlGroup):Actor {
    return _pool.searchGraveRandom(group);
  }

  /**
   * 墓場に移動する
   **/
  public static function moveGrave(actor:Actor):Void {
    _pool.moveGrave(actor);
  }

  /**
   * 墓場にいるActorをすべて実行する
   **/
  public static function forEachGrave(func:Actor->Void):Void {
    _pool.forEachGrave(func);
  }

  /**
   * 指定のグループの生存数を取得する
   **/
  public static function countGroup(group:BtlGroup):Int {
    return _pool.countGroup(group);
  }
}
