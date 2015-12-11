package jp_2dgames.game.state;

import jp_2dgames.game.actor.Params;
import jp_2dgames.game.btl.types.BtlEndResult;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.FlxG;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.DebugActor;
import jp_2dgames.game.actor.TempActorMgr;
import jp_2dgames.game.btl.BtlBg;
import jp_2dgames.game.btl.BtlGroupUtil;
import jp_2dgames.game.btl.BtlMgr;
import jp_2dgames.game.gui.BtlPlayerUI;
import jp_2dgames.game.btl.logic.BtlLogicMgr;
import jp_2dgames.game.particle.ParticleDamage;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.lib.Snd;

/**
 * メインゲーム
 */
class BattleState extends FlxSubState {

  // バトル管理
  var _btlMgr:BtlMgr;

  // 背景
  var _bg:BtlBg;

  // バトル終了時のコールバック
  var _cbBtlEnd:BtlEndResult->Void;

  // バトル開始パラメータ
  var _param:BtlMgrParam;

  /**
   * コンストラクタ
   **/
  public function new(param:BtlMgrParam, cbBtlEnd:BtlEndResult->Void) {
    super();
    _param = param;
    _cbBtlEnd = cbBtlEnd;
  }

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景の表示
    var bg = new BtlBg();
    this.add(bg);

    // キャラクター管理生成
    ActorMgr.create(this);

    // UI登録
    BtlPlayerUI.open(this);

    // バトル管理生成
    _btlMgr = new BtlMgr(this, _param);

    Snd.playSe("enemy");

    // バトル演出キュー
    BtlLogicMgr.create();

    // パーティクルダメージ
    ParticleDamage.create(this);
    // パーティクル
    Particle.create(this);

    // メッセージウィンドウ登録
    var csv = new CsvLoader(Reg.PATH_CSV_MESSAGE);
    Message.createInstancePush(csv, this);


    // デバッグ機能
    FlxG.debugger.toggleKeys = ["ALT"];
  }

  /**
   * 破棄
   */
  override public function destroy():Void {

    super.destroy();

    ParticleDamage.terminate();
    Particle.terminate();
    BtlLogicMgr.destroy();
    ActorMgr.destroy();
    BtlPlayerUI.close(this);
    TempActorMgr.destroy();
    Message.destroyInstance(this);

    // カメラズームをデフォルト値に戻す
    FlxG.camera.zoom = FlxCamera.defaultZoom;
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();

    // バトル更新
    _btlMgr.proc();

    if(_btlMgr.isEnd()) {
      // 戦闘終了
      // バトル終了フラグを設定
      if(Global.isTestBattle() == false) {
        _cbBtlEnd(_btlMgr.btlEnd);
      }

      // おしまい
      active = false;
      FlxG.camera.fade(FlxColor.WHITE, 0.3, false, function() {
        FlxG.camera.fade(FlxColor.WHITE, 0.1, true, null, true);
        close();
      });
    }

    // デバッグ機能
    _updateDebug();
  }

  private function _updateDebug():Void {
    #if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
    #end

    #if debug
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
    if(FlxG.keys.justPressed.Q) {
      // キャラクターパラメータ閲覧
      openSubState(new DebugActor());
    }
    if(FlxG.keys.justPressed.F) {
      // 自爆
      ActorMgr.forEachAliveGroup(BtlGroup.Player, function(actor:Actor) {
        actor.damage(9999);
      });
    }
    if(FlxG.keys.justPressed.D) {
      // 敵を全滅
      ActorMgr.forEachAliveGroup(BtlGroup.Enemy, function(actor:Actor) {
        actor.damage(9999);
      });
    }
    if(FlxG.keys.justPressed.H) {
      // HP回復
      ActorMgr.forEachAliveGroup(BtlGroup.Player, function(actor:Actor) {
        actor.recoverHp(9999);
      });
    }
    #end
  }
}