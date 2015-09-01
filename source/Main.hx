package;

import jp_2dgames.game.BootState;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;
import flixel.FlxState;

class Main extends Sprite {
  var gameWidth:Int = 240; // 画面の幅
  var gameHeight:Int = 426; // 画面の高さ
  var initialState:Class<FlxState> = BootState; // 起動時に開始するシーン
  var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
  var framerate:Int = 60; // How many frames per second the game should run at.
  var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
  var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

  // You can pretty much ignore everything from here on - your code should go in your states.

  public static function main():Void {
    Lib.current.addChild(new Main());
  }

  public function new() {
    super();

    if(stage != null) {
      init();
    }
    else {
      addEventListener(Event.ADDED_TO_STAGE, init);
    }
  }

  private function init(?E:Event):Void {
    if(hasEventListener(Event.ADDED_TO_STAGE)) {
      removeEventListener(Event.ADDED_TO_STAGE, init);
    }

    setupGame();
  }

  private function setupGame():Void {
    var stageWidth:Int = Lib.current.stage.stageWidth;
    var stageHeight:Int = Lib.current.stage.stageHeight;

    if(zoom == -1) {
      var ratioX:Float = stageWidth / gameWidth;
      var ratioY:Float = stageHeight / gameHeight;
      zoom = Math.min(ratioX, ratioY);
      gameWidth = Math.ceil(stageWidth / zoom);
      gameHeight = Math.ceil(stageHeight / zoom);
    }

    addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
  }
}