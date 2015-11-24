package jp_2dgames.game.btl.logic;

import jp_2dgames.game.skill.SkillSlot;
import jp_2dgames.game.actor.BadStatusUtil;
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
      return b.agi - a.agi;
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
      // バステチェック
      if(BadStatusUtil.isActiveActor(actor) == false) {
        // 行動不可
        var eft = BtlLogicFactory.createDeactive(actor);
        push(eft);
        continue;
      }

      // 演出データを生成
      var efts = BtlLogicFactory.create(actor);
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
        var eftList = BtlLogicFactory.createTurnEnd(actor);
        for(eft in eftList) {
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
   * 復活できるかどうか
   **/
  private function _checkAutoRevive(actor:Actor):Bool {
    if(actor.group != BtlGroup.Player) {
      // 復活できない
      return false;
    }

    // 自動復活済みかどうかをチェック
    if(actor.param.bAutoRevive) {
      // すでに復活したので復活できない
      return false;
    }

    // 復活スキルをチェック
    var skillID = SkillSlot.getReviveSkillID();
    if(skillID == 0) {
      // 復活スキルを持っていない
      return false;
    }

    // 復活できる
    return true;
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

      if(_checkAutoRevive(actor2)) {
        // 自動復活できる
        var eftList = BtlLogicFactory.createAutoRevive(actor2);
        for(eft in eftList) {
          push(eft);
        }
      }
      else {
        // 復活できないので死亡
        var eft = BtlLogicFactory.createDead(actor2);
        push(eft);
        // そして墓場送り
        TempActorMgr.moveGrave(actor2);
      }

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
      // ランダムで味方を取得
      var player = TempActorMgr.searchGraveRandom(BtlGroup.Player);
      var eft = BtlLogicFactory.createBtlEnd(player, false);
      push(eft);
      // 終了
      return true;
    }
    else if(TempActorMgr.countGroup(BtlGroup.Enemy) == 0) {
      // 敵が全滅
      // ランダムで味方を取得
      var player = TempActorMgr.random(BtlGroup.Player);
      var eft = BtlLogicFactory.createBtlEnd(player, true);
      push(eft);
      // 終了
      return true;
    }

    // 終了していない
    return false;
  }
}
