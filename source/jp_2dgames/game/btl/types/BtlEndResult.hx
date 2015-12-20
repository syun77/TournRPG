package jp_2dgames.game.btl.types;

import jp_2dgames.game.actor.PartyMgr;
import jp_2dgames.game.actor.Params;

/**
 * バトル終了パラメータ
 **/
class BtlEndResult {

  // バトル終了事由
  public var type:BtlEndType;

  // パラメータ
  private var _paramList:Array<Params>;

  /**
   * コンストラクタ
   **/
  public function new() {
    type = BtlEndType.None;

    // パラメータ作成
    _paramList = new Array<Params>();
    for(i in 0...PartyMgr.PARTY_MAX) {
      var param = new Params();
      _paramList.push(param);
    }
  }

  /**
   * プレイヤーのパラメータ設定
   **/
  public function setParamPlayer(param:Params):Void {
    // パラメータをコピー
    _paramList[PartyMgr.PLAYER_IDX].copy(param);
  }

  /**
   * プレイヤーのパラメータ取得
   **/
  public function getParamPlayer():Params {
    return _paramList[PartyMgr.PLAYER_IDX];
  }

  /**
   * NPCのパラメータ設定
   **/
  public function setParamNpc(idx:Int, param:Params):Void {
    var idx2 = PartyMgr.NPC_IDX_START + idx;
    if(idx2 < 0 || _paramList.length <= idx2) {
      trace('Warning: Invalid idx = ${idx2}');
      return;
    }

    // パラメータをコピー
    _paramList[idx2].copy(param);
  }

  /**
   * NPCのパラメータ取得
   **/
  public function getParamNpc(idx:Int):Params {
    var idx2 = PartyMgr.NPC_IDX_START + idx;
    if(idx2 < 0 || _paramList.length <= idx2) {
      trace('Warning: Invalid idx = ${idx2}');
      return null;
    }

    var param = _paramList[idx2];
    if(param.exists == false) {
      // 存在しない
      return null;
    }

    return param;
  }
}
