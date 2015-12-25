package jp_2dgames.game.actor;

import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.btl.BtlGroupUtil;
/**
 * パーティ(Actor)管理
 **/

class PartyActorMgr {

  var _actorList:Array<Actor>;

  /**
   * コンストラクタ
   **/
  public function new() {

    _actorList = new Array<Actor>();
    for(i in 0...PartyMgr.PARTY_MAX) {
      var actor = new Actor(i);
      _actorList.push(actor);
    }
  }

  /**
   * プレイヤーの生成
   **/
  public function createPlayer(param:Params):Void {
    getPlayer().init(BtlGroup.Player, param);
  }

  /**
   * NPCの生成
   **/
  public function createNpc(idx:Int, param:Params):Void {
    getNpc(idx).init(BtlGroup.Player, param);
  }

  /**
   * PartyMgrからコピーする
   **/
  public function copyFromParam(src:PartyMgr):Void {
    for(i in 0...PartyMgr.PARTY_MAX) {
      var param = src.getParamFromIdx(i);
      _actorList[i].init(BtlGroup.Player, src.getParamFromIdx(i), false);
    }
  }

  /**
   * パーティの生存数を取得する
   **/
  public function countExists():Int {
    var ret:Int = 0;
    for(actor in _actorList) {
      if(actor.param.exists) {
        ret++;
      }
    }
    return ret;
  }

  /**
   * インデックス指定でActorを取得する
   **/
  public function getActorFromIdx(idx:Int):Actor {
    if(idx < 0 || PartyMgr.PARTY_MAX <= idx) {
      return null;
    }

    return _actorList[idx];
  }

  /**
   * プレイヤーパラメータの取得
   **/
  public function getPlayer():Actor {
    return _actorList[PartyMgr.PLAYER_IDX];
  }

  /**
   * NPCパラメータの取得
   **/
  public function getNpc(idx:Int):Actor {
    if(idx < 0 || PartyMgr.NPC_MAX <= idx) {
      return null;
    }
    return _actorList[PartyMgr.NPC_IDX_START + idx];
  }

  /**
   * 未使用のNPCパラメータを取得する
   **/
  public function getEmptyNpc():Actor {
    for(i in 0...PartyMgr.PARTY_MAX) {
      if(i == PartyMgr.PLAYER_IDX) {
        continue;
      }
      var p = _actorList[i];
      if(p.isDead() == false) {
        // 未使用なので使える
        return p;
      }
    }

    // 未使用のパラメータなし
    return null;
  }
}
