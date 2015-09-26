package jp_2dgames.game.btl.logic;

import jp_2dgames.game.btl.logic.BtlLogic.BtlLogicUtil;
import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.gui.BtlUI;
import jp_2dgames.game.particle.ParticleDamage;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxRandom;
import flixel.FlxObject;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import flixel.FlxG;
import flixel.FlxCamera;
import jp_2dgames.lib.Input;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.btl.logic.BtlLogicData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.ActorMgr;

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

  // ■バトル終了条件の取得
  public static inline var BTL_END_NONE:Int   = 0; // なし
  public static inline var BTL_END_ESCAPE:Int = 1; // 逃走
  public static inline var BTL_END_WIN:Int    = 2; // バトル勝利
  public static inline var BTL_END_LOSE:Int   = 3; // バトル敗北

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
  private function _endMain(bWait:Bool):Void {
    _state = State.Wait;
    if(bWait) {
      _tWait = Reg.TIMER_WAIT;
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
        BtlUI.missPlayer(target.ID);
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
      BtlUI.shake();

      // パーティクルの座標取得
      px = BtlUI.getPlayerX(target.ID);
      py = BtlUI.getPlayerY(target.ID);

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
   * 更新・メイン・開始演出
   **/
  private function _updateMainBegin():Void {

    var actor = ActorMgr.search(_data.actorID);
    var target = ActorMgr.search(_data.targetID);

    switch(_data.type) {
      case BtlLogic.BeginAttack:
        // 攻撃
        Message.push2(Msg.ATTACK_BEGIN, [actor.name]);
        if(actor.group == BtlGroup.Enemy) {
          // 攻撃開始エフェクト再生
          var px = actor.xcenter;
          var py = actor.ycenter;
          Particle.start(PType.Ring3, px, py, FlxColor.RED);
        }

      case BtlLogic.BeginSkill(id):
        // スキル
        var name = SkillUtil.getName(id);
        Message.push2(Msg.SKILL_BEGIN, [actor.name, name]);

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
        BtlUI.setActivePlayer(_data.actorID, true);
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

    // ズーム演出
    var obj = _getFollowObj(actor, _data.targetID);
    if(obj != null) {
      FlxG.camera.follow(obj, FlxCamera.STYLE_LOCKON, null, 10);
      _zoom = FlxCamera.defaultZoom + 0.1;
    }

    // メイン処理終了
    _endMain(true);
  }

  /**
   * 更新・メイン
   **/
  private function _updateMain():Void {

    var actor = ActorMgr.search(_data.actorID);
    var target = ActorMgr.search(_data.targetID);

    // 一時停止するかどうか
    var bWait:Bool = true;

    switch(_data.type) {
      case BtlLogic.None, BtlLogic.BeginAttack, BtlLogic.BeginSkill, BtlLogic.BeginItem:
        // ここに来てはいけない
        throw 'Invalid _data.type ${_data.type}';

      case BtlLogic.HpDamage(val, bSeq):
        // HPダメージ
        _damage(target, val, bSeq);

      case BtlLogic.ChanceRoll(b):
        // 成功 or 失敗
        _chanceRool(b);

      case BtlLogic.Badstatus(bst):
        // バステ付着
        target.adhereBadStatus(bst);
        BadStatusUtil.pushMessage(bst, target.name);

      case BtlLogic.Item(item):
        // アイテムを使う
        ItemUtil.use(actor, item);

      case BtlLogic.Escape:
        Message.push2(Msg.ESCAPE, [actor.name]);

      case BtlLogic.Dead:
        ActorMgr.moveGrave(actor);
        Message.push2(Msg.DEFEAT_ENEMY, [actor.name]);
        if(actor.group == BtlGroup.Enemy) {
          // 消滅エフェクト再生
          var px = actor.xcenter;
          var py = actor.ycenter;
          Particle.start(PType.Ring, px, py, FlxColor.YELLOW);
        }

      case BtlLogic.BtlEnd(bWin):
        if(bWin) {
          // 敵が全滅
          Message.push2(Msg.BATTLE_WIN);
        }
        else {
          // 味方が全滅
          Message.push2(Msg.BATTLE_LOSE);
        }
        bWait = false;

      case BtlLogic.EndAction:
        // 行動終了
        _endAction();
        bWait = false;
    }

    // メイン処理終了
    _endMain(bWait);
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
        BtlUI.setActivePlayer(_data.actorID, false);
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
  public function getBtlEnd():Int {
    switch(_data.type) {
      case BtlLogic.Escape(bSuccess):
        if(bSuccess) {
          // 逃走成功
          return BTL_END_ESCAPE;
        }

      case BtlLogic.BtlEnd(bWin):
        if(bWin) {
          // バトル勝利
          return BTL_END_WIN;
        }
        else {
          // バトル敗北
          return BTL_END_LOSE;
        }

      default:
    }

    // 続行
    return BTL_END_NONE;
  }
}
