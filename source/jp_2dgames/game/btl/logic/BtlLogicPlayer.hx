package jp_2dgames.game.btl.logic;

import flixel.util.FlxRandom;
import flixel.FlxObject;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import flixel.FlxG;
import flixel.FlxCamera;
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
  // ズーム倍率
  var _zoom:Float = FlxCamera.defaultZoom;

  public function new(data:BtlLogicData) {
    _data = data;
  }

  private function _getFollowObj(actor:Actor, targetID:Int):FlxObject {
    var obj = new FlxObject();
    if(actor.group == BtlGroup.Enemy) {
      // 主体者をフォーカス
      obj.x = actor.x + actor.width/2;
      obj.y = actor.y + actor.height/2;
    }
    else {
      var target = ActorMgr.search(targetID);
      if(target != null && target.group == BtlGroup.Enemy) {
        // 対象をフォーカス
        obj.x = target.x + target.width/2;
        obj.y = target.y + target.height/2;
      }
      else {
        // フォーカスの対象なし
        return null;
      }
    }

    // ランダムで上下に揺らす
    obj.y += FlxRandom.floatRanged(-8, 8);

    return obj;
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
        Message.push2(Msg.SKILL_BEGIN, [actor.name, 'Skill${id}']);
      case BtlCmd.Item(item, range, targetID):
        var name = ItemUtil.getName(item);
        Message.push2(Msg.ITEM_USE, [name]);
      case BtlCmd.Escape:
        Message.push2(Msg.ESCAPE, [actor.name]);
      case BtlCmd.Dead:
        ActorMgr.moveGrave(actor);
        Message.push2(Msg.DEFEAT_ENEMY, [actor.name]);
    }

    // ズーム演出
    var obj = null;
    switch(_data.cmd) {
      case BtlCmd.Attack(range, targetID):
        obj = _getFollowObj(actor, targetID);
      case BtlCmd.Skill(id, range, targetID):
        obj = _getFollowObj(actor, targetID);
      case BtlCmd.Item(item, range, targetID):
        obj = _getFollowObj(actor, targetID);
      default:
    }
    if(obj != null) {
      FlxG.camera.follow(obj, FlxCamera.STYLE_LOCKON, null, 10);
      _zoom = 2;
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
        // HPダメージ
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
        // TODO: 仮
        switch(_data.target) {
          case BtlRange.One:
            _execTarget(target);
          default:
          // TODO: 未実装
        }

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

    // ズーム計算
    {
      var d = _zoom - FlxG.camera.zoom;
      FlxG.camera.zoom += (d * 0.2);
    }

    if(_checkWait()) {
      // 停止中
      return;
    }

    switch(_state) {
      case State.Init:
      case State.Main:
        _updateMain();
      case State.Wait:
        // ズーム演出
        var obj = new FlxObject();
        obj.x = FlxG.width/2;
        obj.y = FlxG.height/2;
        FlxG.camera.follow(obj, FlxCamera.STYLE_LOCKON, null, 50);
        // デフォルトに戻す
        _zoom = FlxCamera.defaultZoom;
        // おしまい
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
