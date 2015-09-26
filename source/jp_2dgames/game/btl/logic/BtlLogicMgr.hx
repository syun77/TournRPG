package jp_2dgames.game.btl.logic;

import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.ActorMgr;
import haxe.ds.ArraySort;
import jp_2dgames.game.actor.TempActorMgr;
import jp_2dgames.game.actor.Actor;

/**
 * バトル演出管理(キュー)
 **/
class BtlLogicMgr {

  // インスタンス
  private static var _instance:BtlLogicMgr = null;

  /**
   * 生成
   **/
  public static function create():Void {
    if(_instance == null) {
      _instance = new BtlLogicMgr();
    }
  }

  /**
   * 破棄
   **/
  public static function destroy():Void {
    _instance = null;
  }

  /**
   * バトル演出データをキューに登録
   **/
  public static function push(data:BtlLogicData):Void {
    _instance._push(data);
  }
  private function _push(data:BtlLogicData):Void {
    _pool.add(data);
  }

  /**
   * 演出データをキューから取り出す
   **/
  public static function pop():BtlLogicData {
    return _instance._pop();
  }
  private function _pop():BtlLogicData {
    return _pool.pop();
  }

  /**
   * 演出データ作成
   **/
  public static function createLogic():Void {
    _instance._createLogic();
  }
  private function _createLogic():Void {

    // ActorMgrから情報をコピーする
    TempActorMgr.copyFromActorMgr();

    // 行動順の決定
    var actorList = TempActorMgr.getAlive();
    ArraySort.sort(actorList, function(a:Actor, b:Actor) {
      // 移動速度で降順ソート
      return a.agi - b.agi;
    });


    // 行動順に実行
    // バトル終了フラグ
    var bEnd = false;
    for(actor in actorList) {

      // 死亡チェック
      if(actor.isDead()) {
        // 死亡しているので何もしない
        continue;
      }

      // 演出データを生成
      var efts = BtlLogicUtil.create(actor);
      if(efts != null) {
        for(eft in efts) {
          push(eft);
        }
      }

      // 死亡チェック
      _checkDead();

      // バトル終了チェック
      bEnd = _checkBattleEnd();
      if(bEnd) {
        // 行動終了
        break;
      }
    }

    // ターン終了処理
    if(bEnd == false) {
      for(actor in TempActorMgr.getAlive()) {
        var eft = BtlLogicUtil.createTurnEnd(actor);
        if(eft != null) {
          push(eft);
        }

        // 死亡チェック
        _checkDead();

        // バトル終了チェック
        if(_checkBattleEnd()) {
          // 行動終了
          break;
        }
      }
    }
  }


  // ■メンバ変数
  var _pool:List<BtlLogicData>;

  public function new() {
    _pool = new List<BtlLogicData>();
  }

  /**
   * 死亡チェック
   **/
  private function _checkDead():Void {

    // 死亡チェック
    var idx = ActorMgr.MAX;
    while(idx > 0) {

      // 死亡している人を探す
      var actor2 = TempActorMgr.searchDead();
      if(actor2 == null) {
        // 死亡している人はいないのでおしまい
        return;
      }

      // 死亡した人がいる
      var eft = BtlLogicUtil.createDead(actor2);
      push(eft);
      // 墓場送り
      TempActorMgr.moveGrave(actor2);
      idx--;
    }
  }

  /**
   * バトル終了チェック
   * @return 戦闘が終了したらtrue
   **/
  private function _checkBattleEnd():Bool {

    // 全滅チェック
    if(TempActorMgr.countGroup(BtlGroup.Player) == 0) {
      // 味方が全滅
      var eft = BtlLogicUtil.createBtlEnd(false);
      push(eft);
      // 終了
      return true;
    }
    else if(TempActorMgr.countGroup(BtlGroup.Enemy) == 0) {
      // 敵が全滅
      var eft = BtlLogicUtil.createBtlEnd(true);
      push(eft);
      // 終了
      return true;
    }

    // 終了していない
    return false;
  }
}
