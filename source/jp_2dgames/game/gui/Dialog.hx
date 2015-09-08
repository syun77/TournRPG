package jp_2dgames.game.gui;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;

/**
 * ダイアログ
 **/
class Dialog extends FlxGroup {

  // ダイアログの種類
  public static inline var OK:Int      = 0; // ダイアログ
  public static inline var YESNO:Int   = 1; // Yes/Noダイアログ
  public static inline var SELECT2:Int = 2; // 2択ダイアログ
  public static inline var SELECT3:Int = 3; // 3択ダイアログ

  // 選択した項目
  public static inline var BTN_YES:Int = 0; // はい
  public static inline var BTN_NO:Int  = 1; // いいえ

  // 幅
  private static inline var WIDTH:Int = 64;

  // 3択ダイアログのオフセット座標(Y)
  private static inline var SELECT3_OFS_Y:Int = 24;

  // ボタンの間隔
  private static inline var BTN_DY:Int = MyButton.HEIGHT + 2;

  // インスタンス
  private static var _instance:Dialog = null;

  /**
   * 開く
   **/
  public static function open(type:Int, msg:String, sels:Array<String>, cbFunc:Int->Void):Void {
    _instance = new Dialog(type, msg, sels, cbFunc);
    FlxG.state.add(_instance);
  }

  // ■メンバ変数

  /**
   * コンストラクタ
   **/
  public function new(type:Int, msg:String, sels:Array<String>, cbFunc:Int->Void) {
    super();

    var px = FlxG.width/2;
    var py = FlxG.height/2;
    var height = WIDTH;
    if(type == SELECT3) {
      // 広げる
      height = SELECT3_OFS_Y;
    }

    // ウィンドウ
    var spr = new FlxSprite(px, py - height);
    this.add(spr);

    // メッセージ
    var text = new FlxText(px, py - 48, 0, 96);
    text.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    text.text = msg;
    // 中央揃え
    var width = text.textField.textWidth;
    text.x = px - width / 2;
    this.add(text);

    // ウィンドウサイズを設定
    spr.makeGraphic(Std.int(width * 2), height * 2, FlxColor.WHITE);
    spr.color = MyColor.MESSAGE_WINDOW;
    spr.x -= width;
    spr.alpha = 0.5;
    spr.scale.set(0.2, 1);
    FlxTween.tween(spr.scale, {x:1}, 0.2, {ease:FlxEase.expoOut});

    // 選択肢
    var py2 = FlxG.height / 2;
    var labels:Array<String> = [];
    switch(type) {
      case OK:
        labels = ["OK"];

      case YESNO:
        labels = [
          UIMsg.get(UIMsg.YES),
          UIMsg.get(UIMsg.NO)
        ];
      case SELECT2:
        labels = sels;

      case SELECT3:
        labels = sels;
    }

    // 選択肢ボタン登録
    var idx:Int = 0;
    for(str in labels) {
      var btnID = idx;
      var btn = new MyButton(px, py2, str, function() {

        // 決定した
        _pressButton(cbFunc, btnID);
      });
      // センタリング
      btn.x -= btn.width / 2;
      this.add(btn);
      py2 += BTN_DY;

      idx++;
    }
  }

  /**
   * ボタンを押した
   **/
  private function _pressButton(cbFunc:Int->Void, btnID:Int):Void {
    cbFunc(btnID);

    // ウィンドウを消す
    _instance.kill();
    FlxG.state.remove(_instance);
  }
}
