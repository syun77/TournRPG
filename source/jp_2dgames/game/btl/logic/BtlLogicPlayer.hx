package jp_2dgames.game.btl.logic;

import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.btl.types.BtlEndType;
import jp_2dgames.game.btl.logic.BtlLogicBegin;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.item.Inventory;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.btl.logic.BtlLogicData;
import jp_2dgames.game.btl.logic.BtlLogic.BtlLogicUtil;
import jp_2dgames.game.gui.BtlPlayerUI;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.particle.ParticleDamage;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.lib.Input;

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

  /**
   * コンストラクタ
   **/
  public function new(data:BtlLogicData) {
    _data = data;
  }

  /**
   * カメラフォーカス対象の取得
   **/
  private function _getFollowObj(actor:Actor, targetID:Int):FlxObject {

    var obj = new FlxObject();
    if(actor.group == BtlGroup.Enemy) {
      // 主体者をフォーカス
      obj.x = actor.xcenter;
      obj.y = actor.ycenter;
    }
    else {
      var target = ActorMgr.search(targetID);
      if(target != null && target.group == BtlGroup.Enemy) {
        // 対象をフォーカス
        obj.x = target.xcenter;
        obj.y = target.ycenter;
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
    // メイン処理へ
    _state = State.Main;
  }

  /**
   * メイン処理終了
   **/
  private function _endMain(tWait:Int):Void {
    _state = State.Wait;
    _tWait = tWait;
    if(tWait > 0) {
      if(_data.bWaitQuick) {
        // 待ち時間短縮
        _tWait = Reg.TIMER_WAIT_SEQUENCE;
      }
    }
  }

  /**
   * 成功 or 失敗
   **/
  private function _chanceRool(bSuccess:Bool):Void {

    var actor = ActorMgr.search(_data.actorID);
    var target = ActorMgr.search(_data.targetID);

    if(bSuccess == false) {
      // 失敗
      if(target.group == BtlGroup.Player) {
        // プレイヤー
        BtlPlayerUI.missPlayer(target.ID);
      }
      else {
        // 敵
        var px = target.xcenter;
        var py = target.ycenter;
        // MISS表示
        var p = ParticleDamage.start(px, py, -1);
        p.color = MyColor.NUM_MISS;
      }
      Message.push2(Msg.ATTACK_MISS, [target.name]);
      Snd.playSe("miss");
    }
  }

  /**
   * バッドステータス付着
   **/
  private function _adhereBadstatus(target:Actor):Void {
    if(target.group == BtlGroup.Player) {
      BtlPlayerUI.badstatus();
    }
    else {
      target.startAnimColor(MyColor.ASE_BLUE);
    }
  }

  /**
   * ダメージ演出
   **/
  private function _damage(target:Actor, v:Int, bRandom:Bool):Void {

    // ダメージ値反映
    target.damage(v);

    var px:Float = 0;
    var py:Float = 0;
    if(target.group == BtlGroup.Player) {
      // プレイヤーにダメージ
      Message.push2(Msg.DAMAGE_PLAYER, [target.name, v]);

      // UI全体を揺らす
      BtlPlayerUI.shake();

      // ダメージ演出
      BtlPlayerUI.damage(target.ID);

      // パーティクルの座標取得
      px = BtlPlayerUI.getPlayerX(target.ID);
      py = BtlPlayerUI.getPlayerY(target.ID);

    }
    else {

      // 敵にダメージ
      Message.push2(Msg.DAMAGE_ENEMY, [target.name, v]);
      // 揺らす
      target.shake();

      // パーティクルの座標取得
      px = target.xcenter;
      py = target.ycenter;
    }

    // スクロール有効・無効
    var bScroll = (target.group == BtlGroup.Enemy);

    // パーティクル発生
    Particle.start(PType.Circle, px, py, FlxColor.RED, bScroll);

    // SE再生
    Snd.playSe("hit");

    // ダメージ数値
    if(bRandom) {
      px += Reg.getContinuousAttackRandom();
      py += Reg.getContinuousAttackRandom();
    }
    var p = ParticleDamage.start(px, py, v);
    p.color = MyColor.NUM_DAMAGE;
    if(bScroll == false) {
      p.scrollFactor.set(0, 0);
    }
  }

  /**
   * HP回復
   **/
  private function _recoverHp(target:Actor, v:Int):Void {
    target.recoverHp(v);
    Message.push2(Msg.RECOVER_HP, [target.name, v]);
    // SE再生
    Snd.playSe("recover");

    // 数値表示
    var px:Float = 0;
    var py:Float = 0;
    if(target.group == BtlGroup.Player) {
      px = BtlPlayerUI.getPlayerX(target.ID);
      py = BtlPlayerUI.getPlayerY(target.ID);
    }
    else {
      px = target.xcenter;
      py = target.ycenter;
    }
    var p = ParticleDamage.start(px, py, v);
    p.color = MyColor.NUM_RECOVER;
    // スクロール有効・無効
    var bScroll = (target.group == BtlGroup.Enemy);
    if(bScroll == false) {
      p.scrollFactor.set(0, 0);
    }
  }

  /**
   * MP回復
   **/
  private function _recoverMp(target:Actor, v:Int):Void {
    target.recoverMp(v);
    Message.push2(Msg.RECOVER_MP, [target.name, v]);
    // SE再生
    Snd.playSe("recover");

    // 数値表示
    var px:Float = 0;
    var py:Float = 0;
    if(target.group == BtlGroup.Player) {
      px = BtlPlayerUI.getPlayerX(target.ID);
      py = BtlPlayerUI.getPlayerY(target.ID);
    }
    else {
      px = target.xcenter;
      py = target.ycenter;
    }
    var p = ParticleDamage.start(px, py, v);
    p.color = MyColor.NUM_RECOVER;
    // スクロール有効・無効
    var bScroll = (target.group == BtlGroup.Enemy);
    if(bScroll == false) {
      p.scrollFactor.set(0, 0);
    }
  }

  /**
   * 更新・メイン・開始演出
   **/
  private function _updateMainBegin():Void {

    var actor = ActorMgr.search(_data.actorID);
    var target = ActorMgr.search(_data.targetID);
    var tWait = Reg.TIMER_WAIT;
    var bZoom = true;

    switch(_data.type) {
      case BtlLogic.BeginEffect(type):
        // 開始演出
        BtlLogicBeginUtil.start(type, target);

        tWait = 0;     // ウェイトなし
        bZoom = false; // ズームなし

      case BtlLogic.BeginAttack:
        // 攻撃
        Message.push2(Msg.ATTACK_BEGIN, [actor.name]);
        if(actor.group == BtlGroup.Enemy) {
          // 攻撃開始エフェクト再生
          var px = actor.xcenter;
          var py = actor.ycenter;
          Particle.start(PType.Ring3, px, py, FlxColor.RED);
        }
        // ウェイト時間少なめ
        tWait = Reg.TIMER_WAIT_HIT;

      case BtlLogic.BeginSkill(id):
        // スキル
        var name = SkillUtil.getName(id);
        Message.push2(Msg.SKILL_BEGIN, [actor.name, name]);
        if(actor.group == BtlGroup.Enemy) {
          // 攻撃開始エフェクト再生
          var px = actor.xcenter;
          var py = actor.ycenter;
          Particle.start(PType.Ring3, px, py, FlxColor.RED);
        }

      case BtlLogic.BeginItem(item):
        // アイテム
        var name = ItemUtil.getName(item);
        Message.push2(Msg.ITEM_USE, [name]);

      default:
        throw 'Invalid _data.type (${_data.type})';
    }

    // アクティブ状態の設定
    switch(_data.group) {
      case BtlGroup.Player:
        // プレイヤー
        BtlPlayerUI.setActivePlayer(_data.actorID, true);
      case BtlGroup.Enemy:
        // 敵
        ActorMgr.forEachAliveGroup(BtlGroup.Enemy, function(act:Actor) {
          if(_data.actorID != act.ID) {
            // 自分以外は暗くする
            act.changeColor(MyColor.ENEMY_NON_ACTIVE);
          }
        });
      default:
    }

    if(bZoom) {
      // ズーム演出
      var obj = _getFollowObj(actor, _data.targetID);
      if(obj != null) {
        FlxG.camera.follow(obj, FlxCamera.STYLE_LOCKON, null, 10);
        _zoom = FlxCamera.defaultZoom + 0.1;
      }
    }

    // メイン処理終了
    _endMain(tWait);
  }

  private function _searchActorAnywhere(actorID:Int):Actor {
    var ret = ActorMgr.search(actorID);
    if(ret == null) {
      // 見つからなかったので墓場から探す
      ret = ActorMgr.searchGrave(actorID);
    }
    return ret;
  }

  /**
   * 更新・メイン
   **/
  private function _updateMain():Void {

    var actor = _searchActorAnywhere(_data.actorID);
    var target = _searchActorAnywhere(_data.targetID);

    // 停止時間
    var tWait = Reg.TIMER_WAIT;

    switch(_data.type) {
      case BtlLogic.None, BtlLogic.BeginEffect, BtlLogic.BeginAttack, BtlLogic.BeginSkill, BtlLogic.BeginItem:
        // ここに来てはいけない
        throw 'Invalid _data.type ${_data.type}';

      case BtlLogic.SkillCost(hp, mp):
        // スキルコスト消費
        if(hp > 0) {
          actor.damage(hp);
        }
        else {
          actor.damageMp(mp);
        }
        // 一時停止無効
        tWait = 0;

      case BtlLogic.UseItem(item):
        // インベントリから削除
        Inventory.delItem(item.uid);
        // 一時停止無効
        tWait = 0;

      case BtlLogic.Message(msgID):
        // メッセージ表示
        Message.push2(msgID);

      case BtlLogic.Message2(msgID, args):
        // メッセージ表示
        Message.push2(msgID, args);

      case BtlLogic.HpDamage(val, bSeq):
        // HPダメージ
        _damage(target, val, bSeq);

      case BtlLogic.HpRecover(val):
        // HP回復
        _recoverHp(target, val);

      case BtlLogic.MpRecover(val):
        // MP回復
        _recoverMp(target, val);

      case BtlLogic.ChanceRoll(b):
        // 成功 or 失敗
        _chanceRool(b);

      case BtlLogic.Badstatus(bst, val):
        // バステ付着
        if(bst == BadStatus.None) {
          // 回復
          target.cureBadStatus();
        }
        else {
          // 付着
          target.adhereBadStatus(bst, val);
          // 揺らす
          _adhereBadstatus(target);
          BadStatusUtil.pushMessage(bst, target.name);
        }

      case BtlLogic.Buff(atk, def, spd):
        // バフ
        target.addBuffAtk(atk);
        target.addBuffDef(def);
        target.addBuffSpd(spd);

      case BtlLogic.AutoRevive:
        // 自動復活
        target.param.bAutoRevive = true; // 自動復活した
        _tWait = 0;

      case BtlLogic.Escape:
        // 逃走実行

      case BtlLogic.Dead:
        ActorMgr.moveGrave(actor);
        if(actor.group == BtlGroup.Player) {
          // 味方の場合
          Message.push2(Msg.PLAYER_DEAD, [actor.name]);
        }
        if(actor.group == BtlGroup.Enemy) {
          // 敵の場合
          Message.push2(Msg.DEFEAT_ENEMY, [actor.name]);
          // 消滅エフェクト再生
          var px = actor.xcenter;
          var py = actor.ycenter;
          Particle.start(PType.Ring, px, py, FlxColor.YELLOW);
        }
        // SE再生
        Snd.playSe("destroy");

      case BtlLogic.BtlEnd(bWin):
        if(bWin) {
          // 敵が全滅
          Message.push2(Msg.BATTLE_WIN);
        }
        else {
          // 味方が全滅
          //Message.push2(Msg.DEAD, [actor.name]);
        }
        tWait = 0;

      case BtlLogic.EndAction:
        // 行動終了
        _endAction();
        tWait = 0;
    }

    // メイン処理終了
    _endMain(tWait);
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
    if(BtlLogicUtil.isBegin(_data.type))
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
        if(BtlLogicUtil.isBegin(_data.type)) {
          // 開始演出
          _updateMainBegin();
        }
        else {
          // 通常演出
          _updateMain();
        }
      case State.Wait:
        _state = State.End;

      case State.End:

    }
  }

  /**
   * アクション終了
   **/
  private function _endAction():Void {
    // カメラ制御
    var obj = new FlxObject();
    obj.x = FlxG.width/2;
    obj.y = FlxG.height/2;
    FlxG.camera.follow(obj, FlxCamera.STYLE_LOCKON, null, 50);
    // デフォルトに戻す
    _zoom = FlxCamera.defaultZoom;

    switch(_data.group) {
      case BtlGroup.Player:
        // プレイヤー
        BtlPlayerUI.setActivePlayer(_data.actorID, false);
      case BtlGroup.Enemy:
        // 敵
        // 色を戻す
        ActorMgr.forEachAliveGroup(BtlGroup.Enemy, function(act:Actor) {
          if(_data.actorID != act.ID) {
            act.changeColor(FlxColor.WHITE);
          }
        });
      default:
    }
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }

  /**
   * バトル終了条件の取得
   **/
  public function getBtlEnd():BtlEndType {
    switch(_data.type) {
      case BtlLogic.Escape:
        // 逃走成功
        return BtlEndType.Escape;

      case BtlLogic.BtlEnd(bWin):
        if(bWin) {
          // バトル勝利
          return BtlEndType.Win;
        }
        else {
          // バトル敗北
          return BtlEndType.Lose;
        }

      default:
        // 続行
        return BtlEndType.None;
    }
  }
}
