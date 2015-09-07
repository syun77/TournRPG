package jp_2dgames.game.btl;

import jp_2dgames.lib.Input;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.btl.BtlEffectData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.btl.BtlCmdUtil;

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
class BtlEffectPlayer {

  static inline var TIMER_WAIT:Int = 30;

  // 演出情報
  var _data:BtlEffectData;
  // 状態
  var _state:State = State.Init;
  // 停止タイマー
  var _tWait:Int = 0;

  public function new(data:BtlEffectData) {
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
    }

    // メイン処理へ
    _state = State.Main;
    _tWait = TIMER_WAIT;
  }

  /**
   * ターゲットに対する処理
   **/
  private function _execTarget(target:Actor):Void {
    switch(_data.val) {
      case BtlEffectVal.HpDamage(val):
        target.damage(val);
      case BtlEffectVal.HpRecover(val):
      case BtlEffectVal.ChanceRoll(bSuccess):

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
    }

    _state = State.Wait;
    _tWait = TIMER_WAIT;
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
}
