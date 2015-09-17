package jp_2dgames.game.btl.logic;

import jp_2dgames.game.gui.BtlUI;
import jp_2dgames.game.particle.ParticleDamage;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
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

    var actor = ActorMgr.search(_data.actorID);

    switch(_data.cmd) {
      case BtlCmd.None:
        // 通常あり得ない
      case BtlCmd.Attack:
        Message.push2(Msg.ATTACK_BEGIN, [actor.name]);
        if(actor.group == BtlGroup.Enemy) {
          // 攻撃開始エフェクト再生
          var px = actor.xcenter;
          var py = actor.ycenter;
          Particle.start(PType.Ring3, px, py, FlxColor.RED);
        }

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
        if(actor.group == BtlGroup.Enemy) {
          // 消滅エフェクト再生
          var px = actor.xcenter;
          var py = actor.ycenter;
          Particle.start(PType.Ring, px, py, FlxColor.YELLOW);
        }

      case BtlCmd.BtlEnd(bWin):
        if(bWin) {
          // 敵が全滅
          Message.push2(Msg.BATTLE_WIN);
        }
        else {
          // 味方が全滅
          Message.push2(Msg.BATTLE_LOSE);
        }
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
      _zoom = FlxCamera.defaultZoom + 0.1;
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

      case BtlCmd.BtlEnd:
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
        // 終了処理
        _end();
        // おしまい
        _state = State.End;

      case State.End:

    }
  }

  /**
   * 終了
   **/
  private function _end():Void {
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
    switch(_data.cmd) {
      case BtlCmd.Escape(bSuccess):
        if(bSuccess) {
          // 逃走成功
          return BTL_END_ESCAPE;
        }

      case BtlCmd.BtlEnd(bWin):
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
