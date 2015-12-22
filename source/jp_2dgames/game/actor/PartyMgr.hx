package jp_2dgames.game.actor;

/**
 * パーティ管理
 **/
class PartyMgr {

  // パーティの最大数
  public static inline var PARTY_MAX:Int = 3;

  // プレイヤーのインデックスは「0」
  public static inline var PLAYER_IDX:Int = 0;
  // NPCは「1」から開始
  public static inline var NPC_IDX_START:Int = 1;
  // NPCは2人まで
  public static inline var NPC_MAX:Int = 2;

  var _paramList:Array<Params>;

  /**
   * コンストラクタ
   **/
  public function new() {

    _paramList = new Array<Params>();
    for(i in 0...PARTY_MAX) {
      var param = new Params();
      _paramList.push(param);
    }
  }

  /**
   * コピーする
   **/
  public function copy(src:PartyMgr):Void {

    for(i in 0...PARTY_MAX) {
      var p = src.getParamFromIdx(i);
      _paramList[i].copy(p);
    }
  }

  /**
   * PartyActorMgrをコピーする
   **/
  public function copyFromActor(src:PartyActorMgr):Void {

    for(i in 0...PARTY_MAX) {
      var actor = src.getActorFromIdx(i);
      _paramList[i].copy(actor.param);
    }
  }

  /**
   * パーティの生存数を取得する
   **/
  public function countExists():Int {
    var ret:Int = 0;
    for(p in _paramList) {
      if(p.exists) {
        ret++;
      }
    }

    return ret;
  }

  /**
   * インデックス指定でパラメータを取得する
   **/
  public function getParamFromIdx(idx:Int):Params {
    if(idx < 0 || PARTY_MAX <= idx) {
      return null;
    }

    return _paramList[idx];
  }

  /**
   * プレイヤーパラメータの取得
   **/
  public function getPlayerParam():Params {
    return _paramList[PLAYER_IDX];
  }

  /**
   * NPCパラメータの取得
   **/
  public function getNpcParam(idx:Int):Params {
    if(idx < 0 || NPC_MAX <= idx) {
      return null;
    }
    return _paramList[NPC_IDX_START + idx];
  }

  /**
   * 未使用のNPCパラメータを取得する
   **/
  public function getEmptyNpc():Params {
    for(i in 0...PARTY_MAX) {
      if(i == PLAYER_IDX) {
        continue;
      }
      var p = _paramList[i];
      if(p.exists == false) {
        // 未使用なので使える
        return p;
      }
    }

    // 未使用のパラメータなし
    return null;
  }
}
