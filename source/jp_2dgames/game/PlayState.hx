package jp_2dgames.game;

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

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // キャラクター管理生成
    ActorMgr.create(this);

    // UI登録
    _btlUI = new BtlUI();
    this.add(_btlUI);

    // メッセージウィンドウ登録
    var csv = new CsvLoader("assets/data/message.csv");
    Message.instance = new Message(csv);
    this.add(Message.instance);

    // バトル管理生成
    _btlMgr = new BtlMgr(_btlUI);

    FlxG.debugger.toggleKeys = ["ALT"];
  }

  /**
   * 破棄
   */
  override public function destroy():Void {

    ActorMgr.terminate();
    Message.instance = null;

    super.destroy();
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();

    _btlMgr.proc();

    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
  }
}