package jp_2dgames.game.btl.logic;

/**
 * バトル演出管理(キュー)
 **/
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.ActorMgr;
import haxe.ds.ArraySort;
import jp_2dgames.game.actor.TempActorMgr;
import jp_2dgames.game.actor.Actor;
class BtlLogicMgr {
  private static var _instance:BtlLogicMgr = null;

  public static function create():Void {
    if(_instance == null) {
      _instance = new BtlLogicMgr();
    }
  }
  public static function destroy():Void {
    _instance = null;
  }

  public static function push(data:BtlLogicData):Void {
    _instance._push(data);
  }
  private function _push(data:BtlLogicData):Void {
    _pool.add(data);
  }
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

    for(actor in actorList) {
      var eft = BtlLogicUtil.create(actor);
      push(eft);

      // 死亡チェック
      var idx = ActorMgr.MAX;
      while(idx > 0) {
        var actor2 = TempActorMgr.searchDead();
        if(actor2 == null) {
          break;
        }
        // 死亡した人がいる
        var eft = BtlLogicUtil.createDead(actor2);
        push(eft);
        // 墓場送り
        TempActorMgr.moveGrave(actor2);
        idx--;
      }

      // 全滅チェック
      if(TempActorMgr.countGroup(BtlGroup.Player) == 0) {
        // 味方が全滅
        var eft = BtlLogicUtil.createBtlEnd(false);
        push(eft);
        // 終了
        break;
      }
      else if(TempActorMgr.countGroup(BtlGroup.Enemy) == 0) {
        // 敵が全滅
        var eft = BtlLogicUtil.createBtlEnd(true);
        push(eft);
        // 終了
        break;
      }
    }
  }

  // ■メンバ変数
  var _pool:List<BtlLogicData>;

  public function new() {
    _pool = new List<BtlLogicData>();
  }
}
