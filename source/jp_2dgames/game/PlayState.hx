package jp_2dgames.game;

import jp_2dgames.game.actor.PlayerInfo;
import jp_2dgames.game.actor.EnemyInfo;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.DebugActor;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import jp_2dgames.lib.CsvLoader;
import flixel.group.FlxTypedGroup;
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
  var _bg:Bg;
  // デバッグ機能
  var _debugActor:DebugActor;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    Global.init();

    // 背景の表示
    this.add(new Bg());

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

    // デバッグ機能
    _debugActor = new DebugActor();
    this.add(_debugActor);

    FlxG.debugger.toggleKeys = ["ALT"];
  }

  /**
   * 破棄
   */
  override public function destroy():Void {

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
      _debugActor.toggle();
    }
    #end
  }
}