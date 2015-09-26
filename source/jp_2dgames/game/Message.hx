package jp_2dgames.game;

import jp_2dgames.lib.CsvLoader;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * メッセージウィンドウ用のテキスト
 **/
private class MessageText extends FlxText {

  private static inline var BG_OFS_Y = 2;
  // 消えるまでの時間
  private static inline var TIME_KILL = 8.0;

  private var _ofsY:Float = 0;
  public function setOfsY(ofsY:Float) {
    _ofsY = ofsY;
  }
  private var _baseY:Float = 0;

  private var _bg:FlxSprite;
  public var bg(get, never):FlxSprite;
  private function get_bg() {
    return _bg;
  }

  public function new(X:Float, Y:Float, Width:Float) {
    super(X, Y, Width);
    setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    // アウトラインをつける
    setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.BLACK, 1);
    color = FlxColor.WHITE;
    // じわじわ表示
    alpha = 0;
    FlxTween.tween(this, {alpha:1}, 0.3, {ease:FlxEase.sineOut});
    // スライド表示
    var xnext = x;
    x += 64;
    FlxTween.tween(this, {x:xnext}, 0.3, {ease:FlxEase.expoOut});
    // 消滅判定
    new FlxTimer(TIME_KILL, function(t:FlxTimer) {
      // じわじわ消す
      FlxTween.tween(this, {_baseY:-8}, 0.3, {ease:FlxEase.sineOut});
      FlxTween.tween(this, {alpha:0}, 0.3, {ease:FlxEase.sineOut, complete:function(tween:FlxTween) {
        kill();
      }});
    });

    // 背景作成
    _bg = new FlxSprite(X-8, Y+BG_OFS_Y, Reg.PATH_MSG_TEXT);
    _bg.alpha = 0;
    _bg.color = MyColor.MESSAGE_WINDOW;
  }
  override public function kill():Void {
    super.kill();
    _bg.kill();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    y = _baseY + _ofsY;
    _bg.y = y + BG_OFS_Y;
    _bg.alpha = alpha*0.5;
  }
}

/**
 * メッセージウィンドウ
 **/
class Message extends FlxGroup {

  // メッセージログの最大
  private static inline var MESSAGE_MAX = 5;
  // ウィンドウ座標
  private static inline var POS_X = 8;
  private static inline var POS_Y = 184 - HEIGHT - 24 - 8;
  // ウィンドウサイズ
  private static inline var WIDTH = 640 - 8 * 2;
  private static inline var HEIGHT = (MESSAGE_MAX*DY)+14;
  private static inline var MSG_POS_X = 8;
  private static inline var MSG_POS_Y = 8;
  // メッセージ表示間隔
  private static inline var DY = 14;

  // ウィンドウが消えるまでの時間 (5sec)
  private static inline var TIMER_DISAPPEAR:Float = 5;

  // インスタンス
  public static var instance:Message = null;

  // メッセージの追加
  public static function push(msg:String, color:Int=FlxColor.WHITE) {
    Message.instance._push(msg, color);
  }

  public static function push2(msgId:Int, args:Array<Dynamic>=null) {
    if(Message.instance != null) {
      Message.instance._push2(msgId, args);
    }
  }

  // メッセージの取得
  public static function getText(msgId:Int):String {
    return Message.instance._getText(msgId);
  }

  // メッセージウィンドウを消す
  public static function hide() {
    Message.instance.visible = false;
  }

  // ウィンドウの色を変える
  public static function setWindowColor(color:Int):Void {
    Message.instance._window.color = color;
  }

  private var _window:FlxSprite;
  private var _msgList:List<MessageText>;

  // ウィンドウを下に表示しているかどうか
  private var _bDispBottom:Bool = true;
  public static function isDispBottom():Bool {
    return instance._bDispBottom;
  }

  // ウィンドウが消えるまでの時間
  private var _timer:Float;

  // メッセージCSV
  private var _csv:CsvLoader;
  // ヒントメッセージCSV
  private var _csvHint:CsvLoader;

  // テキストのオフセット座標
  private var _txtOfsY:Float = 0;

  /**
   * コンストラクタ
   **/
  public function new(csv:CsvLoader) {
    super();
    // 背景枠
    _window = new FlxSprite(POS_X, POS_Y, Reg.PATH_MSG);
    _window.color = MyColor.MESSAGE_WINDOW;
    //    this.add(_window);
    _msgList = new List<MessageText>();

    // CSVメッセージ
    _csv = csv;

    // 非表示
    visible = false;
  }

  private var ofsY(get_ofsY, never):Float;

  private function get_ofsY() {
    return POS_Y;
  }

  /**
	 * 更新
	 **/
  override public function update():Void {
    super.update();

    _txtOfsY *= 0.9;

    for(text in _msgList) {
      if(text.alive == false) {
        pop();
        _txtOfsY += DY;
      }
    }

    // 座標更新
    _window.y = ofsY;
    _updateTextPosition();
  }

  private function _updateTextPosition():Void {
    var idx = 0;
    for(text in _msgList) {
      // 描画基準座標
      var offsetY = ofsY + MSG_POS_Y;
      // テキストごとのオフセット
      offsetY += idx * DY;
      // テキスト消去によるオフセット
      offsetY += _txtOfsY;
      text.setOfsY(offsetY);
      idx++;
    }
  }

  /**
	 * メッセージを末尾に追加
	 **/
  private function _push(msg:String, color:Int) {
    if(_msgList.length >= MESSAGE_MAX) {
      // 最大を超えたので先頭のメッセージを削除
      pop();
    }

    var text = new MessageText(POS_X + MSG_POS_X, 0, WIDTH);
    text.text = msg;
    text.color = color;
    text.scrollFactor.set(0, 0);
    text.bg.scrollFactor.set(0, 0);
    _msgList.add(text);

    // 座標を更新
    _updateTextPosition();
    for(txt in _msgList) {
      txt.update();
    }
    this.add(text.bg);
    this.add(text);

    // 表示する
    visible = true;
    _timer = TIMER_DISAPPEAR;
  }

  private function _push2(msgId:Int, args:Array<Dynamic>):Void {
    var msg = _csv.getString(msgId, "msg");
    var color = MyColor.strToColor(_csv.getString(msgId, "color"));
    if(args != null) {
      var idx:Int = 1;
      for(val in args) {
        msg = StringTools.replace(msg, '<val${idx}>', '${val}');
        idx++;
      }
    }
    _push(msg, color);
  }

  /**
   * メッセージを取得する
   * @param msgId メッセージID
   * @return メッセージ
   **/
  private function _getText(msgId:Int):String {
    return _csv.searchItem("id", '${msgId}', "msg");
  }

  /**
	 * 先頭のメッセージを削除
	 **/
  public function pop() {
    var t = _msgList.pop();
    this.remove(t.bg);
    this.remove(t);
  }
}

