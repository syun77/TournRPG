package jp_2dgames.game.actor;

import jp_2dgames.game.btl.BtlGroupUtil;
import flixel.FlxState;

/**
 * キャラクター管理
 **/
class ActorMgr  {
  // 生成インスタンス数
  public static inline var MAX:Int = 16;

  static var _pool:ActorPool = null;

  /**
   * 生成
   **/
  public static function create(state:FlxState) {
    if(_pool == null) {
      _pool = new ActorPool(state, MAX);
    }
  }

  /**
   * 末期化
   **/
  public static function destroy() {
    _pool = null;
  }

  /**
   * インスタンスを新規に取得
   **/
  public static function recycle(group:BtlGroup, param:Params):Actor {
    return _pool.recycle(group, param);
  }

  /**
   * 指定したIDに一致するインスタンスを取得
   **/
  public static function search(id:Int):Actor {
    return _pool.search(id);
  }

  /**
   * 指定したIDに一致するインスタンスを取得する (墓場を含める)
   **/
  public static function searchAll(id:Int):Actor {
    var actor = _pool.search(id);
    if(actor != null) {
      // 見つかった
      return actor;
    }

    // 見つからないので墓場から探す
    return searchGrave(id);
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
   * Actorをすべて実行
  */
  public static function forEach(func:Actor->Void):Void {
    _pool.forEach(func);
  }

  /**
   * 生存している指定のグループをすべて実行
   **/
  public static function forEachAliveGroup(group:BtlGroup, func:Actor->Void):Void {
    _pool.forEachAliveGroup(group, func);
  }

  /**
   * 生存しているActorから条件に一致した最初のActorを取得する
   **/
  public static function forEachAliveFirstIf(func:Actor->Bool):Actor {
    return _pool.forEachAliveFirstIf(func);
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
   * 墓場から指定のActorを探す
   **/
  public static function searchGrave(id:Int):Actor {
    return _pool.searchGrave(id);
  }

  /**
   * 指定のグループの生存数を取得する
   **/
  public static function countGroup(group:BtlGroup):Int {
    return _pool.countGroup(group);
  }

  /**
   * 敵のAIを設定する
   **/
  public static function requestEnemyAI():Void {
    _pool.requestEnemyAI();
  }

  /**
   * プレイヤーを取得する
   **/
  public static function getPlayer():Actor {
    return forEachAliveFirstIf(function(actor:Actor) {
      return actor.isPlayer();
    });
  }

  /**
   * NPCを取得する
   **/
  public static function getNpc(idx:Int):Actor {
    return forEachAliveFirstIf(function(actor:Actor) {
      return actor.isNpc(idx);
    });
  }

  /**
   * デバッグ出力
   **/
  public static function dump():Void {
    _pool.forEach(function(actor:Actor) {
      if(actor.ID == -1) {
        return;
      }
      trace("ID:", actor.ID, " hp:", actor.hp, " exists:", actor.exists);
    });
  }
}
