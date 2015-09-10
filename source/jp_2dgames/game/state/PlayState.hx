package jp_2dgames.game.state;

import jp_2dgames.game.save.Save;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.btl.logic.BtlLogicMgr;
import jp_2dgames.game.btl.BtlBg;
import jp_2dgames.game.btl.BtlMgr;
import jp_2dgames.game.gui.BtlUI;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.DebugActor;
import jp_2dgames.lib.CsvLoader;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム
 */
class PlayState extends FlxState {

  // バトル管理
  var _btlMgr:BtlMgr;
  // バトルUI
  var _btlUI:BtlUI;

  // 背景
  var _bg:BtlBg;
  // デバッグ機能
  var _debugActor:DebugActor;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景の表示
    this.add(new BtlBg());

    // キャラクター管理生成
    ActorMgr.create(this);

    // UI登録
    _btlUI = new BtlUI();
    this.add(_btlUI);

    // メッセージウィンドウ登録
    var csv = new CsvLoader(Reg.PATH_CSV_MESSAGE);
    Message.instance = new Message(csv);
    this.add(Message.instance);

    // バトル管理生成
    _btlMgr = new BtlMgr(_btlUI);

    // バトル演出キュー
    BtlLogicMgr.create();

    // デバッグ機能
    _debugActor = new DebugActor();
    this.add(_debugActor);

    FlxG.debugger.toggleKeys = ["ALT"];
  }

  /**
   * 破棄
   */
  override public function destroy():Void {

    BtlLogicMgr.destroy();
    ActorMgr.destroy();
    Message.instance = null;

    super.destroy();
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();

    // バトル更新
    _btlMgr.proc();

    if(_btlMgr.isEnd()) {
      // 次のステージへ
      Global.nextStage();
      FlxG.switchState(new PlayState());
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
      _debugActor.toggle();
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
    if(FlxG.keys.justPressed.S) {
      // セーブ
      Save.save(true, true);
    }
    if(FlxG.keys.justPressed.A) {
      // ロード
      Save.load(true, true);
    }
    #end
  }
}