package jp_2dgames.game.state;
import jp_2dgames.game.gui.MyButton2;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

/**
 * リザルト画面
 **/
class ResultState extends FlxState {

  static inline var TEXT_X = 16;
  static inline var TEXT_Y = 128;
  static inline var TEXT_DY = 24;

  var _xtext:Float = TEXT_X;
  var _ytext:Float = TEXT_Y;
  var _txtTbl:Array<FlxText>;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    var txt = new FlxText(0, 32, FlxG.width, "Result", 24);
    txt.alignment = "center";
    this.add(txt);

    _txtTbl = new Array<FlxText>();

    var exp = Global.getPlayerParam().xp;
    var money = Global.getMoney();
    var score = exp + money;
    _addText('EXP: ${exp}');
    _addText('MONEY: ${money}');
    _addText("");
    _addText('YOUR SCORE');
    _addText('${score}');

    var idx = 0;
    for(txt in _txtTbl) {
      this.add(txt);
      var px = txt.x;
      txt.x = FlxG.width + txt.fieldWidth;
      FlxTween.tween(txt, {x:px}, 0.8, {ease:FlxEase.expoOut, startDelay:idx*0.2});
      idx++;
    }

    var px = FlxG.width/2 - MyButton2.WIDTH/2;
    var py = FlxG.height - 128;
    var btn = new MyButton2(px, py, "BACK TO TITLE", function() {
      FlxG.switchState(new TitleState());
    });
    this.add(btn);
  }

  private function _addText(msg:String):FlxText {
    var txt = new FlxText(_xtext, _ytext, FlxG.width, msg, 20);
    txt.alignment = "center";
    _txtTbl.push(txt);
    _ytext += TEXT_DY;
    return txt;
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    #if neko
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
    #end
  }
}
