package jp_2dgames.game.btl.logic;

import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.lib.Input;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.btl.logic.BtlLogicData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.btl.types.BtlCmd;

/**
 * 状態
 **/
private enum State {
  Init; // 初期化
  Main; // メイン
  Wait; // 終了待ち
  End;  // 終了
}

/**
 * バトル演出の再生
 **/
class BtlLogicPlayer {

  // 演出情報
  var _data:BtlLogicData;
  // 状態
  var _state:State = State.Init;
  // 停止タイマー
  var _tWait:Int = 0;

  public function new(data:BtlLogicData) {
    _data = data;
  }

  /**
   * 開始演出を再生
   **/
  public function start():Void {

    var actor = ActorMgr.search(_data.actorID);

    switch(_data.cmd) {
      case BtlCmd.None:
        // 通常あり得ない
      case BtlCmd.Attack:
        Message.push2(Msg.ATTACK_BEGIN, [actor.name]);
      case BtlCmd.Skill(id, range, targetID):
        // TODO:
      case BtlCmd.Item(item, range, targetID):
        var name = ItemUtil.getName(item);
        Message.push2(Msg.ITEM_USE, [name]);
      case BtlCmd.Escape:
        Message.push2(Msg.ESCAPE, [actor.name]);
      case BtlCmd.Dead:
        ActorMgr.moveGrave(actor);
        Message.push2(Msg.DEFEAT_ENEMY, [actor.name]);
    }

    // メイン処理へ
    _state = State.Main;
    _tWait = Reg.TIMER_WAIT;
  }

  /**
   * ターゲットに対する処理
   **/
  private function _execTarget(target:Actor):Void {
    switch(_data.val) {
      case BtlLogicVal.HpDamage(val):
        target.damage(val);
      case BtlLogicVal.HpRecover(val):
      case BtlLogicVal.ChanceRoll(bSuccess):

    }
  }

  private function _updateMain():Void {

    var actor = ActorMgr.search(_data.actorID);
    var target = ActorMgr.search(_data.targetID);

    switch(_data.cmd) {
      case BtlCmd.None:
        // 通常ここにくることはない

      case BtlCmd.Attack:
        // 通常攻撃
        switch(_data.target) {
          case BtlRange.One:
            _execTarget(target);
          default:
            // TODO: 未実装
        }

      case BtlCmd.Skill(id, range, targetID):
        // スキルを使う

      case BtlCmd.Item(item, range, targetID):
        // アイテムを使う
        ItemUtil.use(actor, item);

      case BtlCmd.Escape:

      case BtlCmd.Dead:
    }

    _state = State.Wait;
    _tWait = Reg.TIMER_WAIT;
  }

  private function _checkWait():Bool {
    if(_tWait > 0) {
      _tWait--;
      if(Input.press.A) {
        // 演出ウェイトスキップ
        _tWait = 0;
      }
      if(_tWait > 0) {
        // 停止中
        return true;
      }
    }

    // 停止しない
    return false;
  }

  /**
   * 更新
   **/
  public function update():Void {

    if(_checkWait()) {
      // 停止中
      return;
    }

    switch(_state) {
      case State.Init:
      case State.Main:
        _updateMain();
      case State.Wait:
        _state = State.End;
      case State.End:
    }
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }

  /**
   * 逃走に成功したかどうか
   **/
  public function isEscape():Bool {
    switch(_data.cmd) {
      case BtlCmd.Escape(bSuccess):
        return bSuccess;
      default:
        return false;
    }
  }
}
