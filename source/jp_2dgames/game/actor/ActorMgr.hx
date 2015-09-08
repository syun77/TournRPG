package jp_2dgames.game.actor;

import jp_2dgames.game.btl.BtlGroupUtil;
import flixel.util.FlxRandom;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * キャラクター管理
 **/
class ActorMgr  {
  // 生成インスタンス数
  static inline var MAX:Int = 16;

  static var _instance:FlxTypedGroup<Actor> = null;
  // 墓地
  static var _graves:Array<Actor> = null;

  /**
   * 生成
   **/
  public static function create(state:FlxState) {
    if(_instance == null) {
      // 16体作る
      _instance = new FlxTypedGroup<Actor>(MAX);
      for(i in 0..._instance.maxSize) {
        _instance.add(new Actor(i));
      }
      state.add(_instance);

      // 死亡リスト
      _graves = new Array<Actor>();
    }
  }

  /**
   * 末期化
   **/
  public static function destroy() {
    _instance = null;
  }

  /**
   * インスタンスを新規に取得
   **/
  public static function recycle(group:BtlGroup, param:Params):Actor {
    var actor:Actor = _instance.recycle();
    actor.init(group, param);
    return actor;
  }

  /**
   * 指定したIDに一致するインスタンスを取得
   **/
  public static function search(id:Int):Actor {
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
  public static function getAlive():Array<Actor> {
    var ret = new Array<Actor>();
    forEachAlive(function(actor:Actor) {
      ret.push(actor);
    });
    return ret;
  }

  /**
   * 生存しているActorをすべて実行
  **/
  public static function forEachAlive(func:Actor->Void):Void {
    _instance.forEachAlive(func);
  }

  /**
   * 生存している指定のグループをすべて実行
   **/
  public static function forEachAliveGroup(group:BtlGroup, func:Actor->Void):Void {
    forEachAlive(function(actor:Actor) {
      if(actor.group == group) {
        func(actor);
      }
    });
  }

  /**
   * 生存しているActorから条件に一致した最初のActorを取得する
   **/
  public static function forEachAliveFirstIf(func:Actor->Bool):Actor {
    for(actor in _instance.members) {
      if(func(actor)) {
        return actor;
      }
    }

    // 見つからなかった
    return null;
  }

  /**
   * 指定のグループからランダムに取得する
   **/
  public static function random(group:BtlGroup):Actor {
    var list = new Array<Actor>();
    forEachAlive(function(actor:Actor) {
      if(BtlGroupUtil.isSame(actor.ID, group)) {
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
  public static function searchDead():Actor {
    return forEachAliveFirstIf(function(actor:Actor) {
      return actor.isDead();
    });
  }

  /**
   * 墓場に移動する
   **/
  public static function moveGrave(actor:Actor):Void {
    if(actor.group == BtlGroup.Enemy) {
      Message.push2(4, [actor.name]);
    }

    actor.kill();
    // 墓場送り
    _graves.push(actor);
  }

  /**
   * 指定のグループの生存数を取得する
   **/
  public static function countGroup(group:BtlGroup):Int {
    var ret:Int = 0;
    forEachAliveGroup(group, function(actor:Actor) {
      ret++;
    });

    return ret;
  }

  /**
   * 敵のAIを設定する
   **/
  public static function requestEnemyAI():Void {
    forEachAliveGroup(BtlGroup.Enemy, function(actor:Actor) {
      actor.requestAI();
    });
  }
}
