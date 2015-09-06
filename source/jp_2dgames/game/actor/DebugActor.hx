package jp_2dgames.game.actor;
import jp_2dgames.lib.Input;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * キャラクターデバッグ機能
 **/
class DebugActor extends FlxSpriteGroup {

  // 背景のサイズ
  static inline var BG_WIDTH:Int = 128;
  static inline var BG_HEIGHT:Int = 128;

  // テキストの座標
  static inline var TEXT_X:Int = 16;
  static inline var TEXT_Y:Int = 16;
  static inline var TEXT_DY:Int = 12;

  // ページ情報
  var _nPage:Int;
  var _nPageMax:Int;
  var _txtPage:FlxText;

  var _actorList:Array<Actor>;

  var _txtID:FlxText;
  var _txtName:FlxText;
  var _txtGroup:FlxText;
  var _txtHp:FlxText;
  var _txtStr:FlxText;
  var _txtVit:FlxText;
  var _txtAgi:FlxText;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(16, 16);

    var bg = new FlxSprite().makeGraphic(BG_WIDTH, BG_HEIGHT, FlxColor.BLACK);
    bg.alpha = 0.8;
    this.add(bg);

    _txtPage = new FlxText(0, 0);
    _txtPage.color = FlxColor.SILVER;
    this.add(_txtPage);

    var txtList = new List<FlxText>();
    var px = TEXT_X;
    var py = TEXT_Y;
    _txtID = new FlxText(px, py);
    txtList.add(_txtID);
    py += TEXT_DY;
    _txtName = new FlxText(px, py);
    txtList.add(_txtName);
    _txtName.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    py += TEXT_DY;
    _txtGroup = new FlxText(px, py);
    txtList.add(_txtGroup);
    py += TEXT_DY;
    _txtHp = new FlxText(px, py);
    txtList.add(_txtHp);
    py += TEXT_DY;
    _txtStr = new FlxText(px, py);
    txtList.add(_txtStr);
    py += TEXT_DY;
    _txtVit = new FlxText(px, py);
    txtList.add(_txtVit);
    py += TEXT_DY;
    _txtAgi = new FlxText(px, py);
    txtList.add(_txtAgi);
    py += TEXT_DY;

    for(txt in txtList) {
      this.add(txt);
    }

    // 非表示
    visible = false;
  }

  /**
   * 表示・非表示の切り替え
   **/
  public function toggle():Void {
    if(visible == false) {
      // 開く
      visible = true;

      _nPage = 0;
      _actorList = ActorMgr.getAlive();
      _nPageMax = _actorList.length;

      _setText(_nPage);
    }
    else {
      // 閉じる
      visible = false;
    }
  }

  /**
   * テキストを設定
   **/
  private function _setText(idx:Int):Void {
    _txtPage.text = 'page(${idx}/${_nPageMax-1})';

    var act = _actorList[idx];

    _txtID.text    = 'ID: ${act.ID}';
    _txtName.text  = ${act.name};
    _txtGroup.text = 'Grp: ${act.group}';
    _txtHp.text    = 'HP: ${act.hp}/${act.hpmax}';
    _txtStr.text   = 'STR: ${act.str}';
    _txtVit.text   = 'VIT: ${act.vit}';
    _txtAgi.text   = 'AGI: ${act.agi}';
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // ページ切り替え
    if(Input.press.LEFT) {
      _nPage--;
      if(_nPage < 0) {
        _nPage = _nPageMax-1;
      }
      _setText(_nPage);
    }
    if(Input.press.RIGHT) {
      _nPage++;
      if(_nPage >= _nPageMax) {
        _nPage = 0;
      }
      _setText(_nPage);
    }
  }
}
