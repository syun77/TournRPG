package jp_2dgames.game.actor;

import jp_2dgames.game.btl.BtlGroupUtil;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import flixel.FlxState;
import flixel.util.FlxRandom;
import jp_2dgames.game.btl.BtlGroupUtil;
import flixel.group.FlxTypedGroup;

/**
 * キャラクターオブジェクトのプーリング
 **/
class ActorPool {

  var _pool:FlxTypedGroup<Actor>;
  var _graves:Array<Actor>;

  /**
   * コンストラクタ
   **/
  public function new(state:FlxState, size:Int) {

    // 生存オブジェクト
    _pool = new FlxTypedGroup<Actor>(size);
    for(i in 0..._pool.maxSize) {
      _pool.add(new Actor(i));
    }
    if(state != null) {
      state.add(_pool);
    }

    // 死亡リスト
    _graves = new Array<Actor>();
  }

  /**
   * インスタンスを新規に取得
   **/
  public function recycle(group:BtlGroup, param:Params):Actor {
    var actor:Actor = _pool.recycle();
    actor.init(group, param);
    return actor;
  }

  /**
   * 指定したIDに一致するインスタンスを取得
   **/
  public function search(id:Int):Actor {
    var ret:Actor = null;
    forEachAlive(function(actor:Actor) {
      if(id == actor.ID) {
        ret = actor;
      }
    });

    return ret;
  }

  /**
   * 生存しているActorのリストを取得
   **/
  public function getAlive():Array<Actor> {
    var ret = new Array<Actor>();
    forEachAlive(function(actor:Actor) {
      ret.push(actor);
    });
    return ret;
  }

  /**
   * 生存しているActorをすべて実行
   **/
  public function forEachAlive(func:Actor->Void):Void {
    _pool.forEachAlive(func);
  }

  /**
   * Actorをすべて実行
   */
  public function forEach(func:Actor->Void):Void {
    _pool.forEach(func);
  }

  /**
   * 生存している指定のグループをすべて実行
   **/
  public function forEachAliveGroup(group:BtlGroup, func:Actor->Void):Void {
    forEachAlive(function(actor:Actor) {
      if(BtlGroupUtil.isSame(actor.group, group)) {
        func(actor);
      }
    });
  }

  /**
   * 生存しているActorから条件に一致した最初のActorを取得する
   **/
  public function forEachAliveFirstIf(func:Actor->Bool):Actor {
    for(actor in _pool.members) {
      if(actor.exists) {
        if(func(actor)) {
          return actor;
        }
      }
    }

    // 見つからなかった
    return null;
  }

  /**
   * 指定のグループからランダムに取得する
   **/
  public function random(group:BtlGroup):Actor {
    var list = new Array<Actor>();
    forEachAlive(function(actor:Actor) {
      if(BtlGroupUtil.isSameFromID(actor.ID, group)) {
        // グループが一致
        list.push(actor);
      }
    });

    if(list.length == 0) {
      return null;
    }

    var idx = FlxRandom.intRanged(0, list.length - 1);
    return list[idx];
  }

  /**
   * 死亡しているActorを探す
   **/
  public function searchDead():Actor {
    return forEachAliveFirstIf(function(actor:Actor) {
      return actor.isDead();
    });
  }

  /**
   * 墓場に移動する
   **/
  public function moveGrave(actor:Actor):Void {
    actor.kill();
    // 墓場送り
    _graves.push(actor);
  }

  /**
   * 墓場にいるActorをすべて実行する
   **/
  public function forEachGrave(func:Actor->Void):Void {
    for(actor in _graves) {
      func(actor);
    }
  }

  /**
   * 墓場から指定のActorを探す
   **/
  public function searchGrave(id:Int):Actor {
    var ret:Actor = null;
    forEachGrave(function(actor:Actor) {
      if(id == actor.ID) {
        ret = actor;
      }
    });

    return ret;
  }

  /**
   * 指定のグループの生存数を取得する
   **/
  public function countGroup(group:BtlGroup):Int {
    var ret:Int = 0;
    forEachAliveGroup(group, function(actor:Actor) {
      ret++;
    });

    return ret;
  }

  /**
   * 敵のAIを設定する
   **/
  public function requestEnemyAI():Void {
    forEachAliveGroup(BtlGroup.Enemy, function(actor:Actor) {
      actor.requestAI();
    });
  }
}
