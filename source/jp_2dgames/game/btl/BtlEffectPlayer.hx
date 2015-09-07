package jp_2dgames.game.btl;

import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.btl.BtlEffectData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.btl.BtlCmdUtil;

/**
 * バトル演出の再生
 **/
class BtlEffectPlayer {

  // 演出情報
  var _data:BtlEffectData;
  // 演出が終了したかどうか
  var _bEnd:Bool = false;

  public function new(data:BtlEffectData) {
    _data = data;
  }

  /**
   * 開始演出を再生
   **/
  public function begin():Void {

    var actor = ActorMgr.search(_data.actorID);

    switch(_data.cmd) {
      case BtlCmd.None:
        // 通常あり得ない
      case BtlCmd.Attack:
        Message.push2(Msg.ATTACK_BEGIN, [actor.name]);
      case BtlCmd.Skill:
        // TODO:
      case BtlCmd.Item(item, target, targetID):
        var name = ItemUtil.getName(item);
        Message.push2(Msg.ITEM_USE, [name]);
      case BtlCmd.Escape:
        Message.push2(Msg.ESCAPE, [actor.name]);
    }
  }

  /**
   * 実行
   **/
  public function exec():Void {

    var actor = ActorMgr.search(_data.actorID);
    var target = ActorMgr.search(_data.targetID);

    switch(_data.cmd) {
      case BtlCmd.None:
        // 通常ここにくることはない

      case BtlCmd.Attack:
        // 通常攻撃
        switch(_data.target) {
          case BtlTarget.One:
            _execTarget(target);
          default:
            // TODO: 未実装
        }

      case BtlCmd.Skill(id, target, targetID):
        // スキルを使う

      case BtlCmd.Item(item, target, targetID):
        // アイテムを使う
        ItemUtil.use(actor, item);

      case BtlCmd.Escape:
    }
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

  /**
   * 更新
   **/
  public function update():Void {
    // TODO: 未実装
    _bEnd = true;
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _bEnd;
  }
}
