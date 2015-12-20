package jp_2dgames.game.actor;

/**
 * パーティ管理
 **/
class PartyMgr {

  // パーティの最大数
  static inline var PARTY_MAX:Int = 3;

  // プレイヤーのインデックスは「0」
  public static inline var PLAYER_IDX:Int = 0;
  // NPCは「1」から開始
  static inline var NPC_IDX_START:Int = 1;
  // NPCは2人まで
  static inline var NPC_MAX:Int = 2;

  // ■static 変数
  // シングルトン
  static var _instance:PartyMgr = null;

  // ■static 関数
  /**
   * 生成
   **/
  public static function create():Void {
    _instance = new PartyMgr();
  }

  /**
   * 破棄
   **/
  public static function destroy():Void {
    _instance = null;
  }

  /**
   * パーティの数を取得する
   **/
  public static function countExists():Int {
    return _instance._countExists();
  }

  /**
   * インデックス指定でパラメータを取得する
   **/
  public static function getParamFromIdx(idx:Int):Params {
    return _instance._getParamFromIdx(idx);
  }

  /**
   * プレイヤーパラメータの取得
   **/
  public static function getPlayerParam():Params {
    return _instance._getPlayerParam();
  }

  /**
   * NPCパラメータの取得
   **/
  public static function getNpcParam(idx:Int):Params {
    return _instance._getNpcParam(idx);
  }

  /**
   * 未使用のNPCパラメータを取得する
   **/
  public static function getEmptyNpc():Params {
    return _instance._getEmptyNpc();
  }

  // ==================================================
  // ■以下インスタンス変数
  // ==================================================
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
   * パーティの生存数を取得する
   **/
  private function _countExists():Int {
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
  private function _getParamFromIdx(idx:Int):Params {
    if(idx < 0 || idx <= PARTY_MAX) {
      return null;
    }

    return _paramList[idx];
  }

  /**
   * プレイヤーパラメータの取得
   **/
  private function _getPlayerParam():Params {
    return _paramList[PLAYER_IDX];
  }

  /**
   * NPCパラメータの取得
   **/
  private function _getNpcParam(idx:Int):Params {
    if(idx < 0 || NPC_MAX <= idx) {
      return null;
    }
    return _paramList[NPC_IDX_START + idx];
  }

  /**
   * 未使用のNPCパラメータを取得する
   **/
  private function _getEmptyNpc():Params {
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
