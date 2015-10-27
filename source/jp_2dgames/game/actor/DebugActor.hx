package jp_2dgames.game.actor;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import flixel.FlxG;
import flixel.FlxSubState;
import jp_2dgames.lib.Input;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * キャラクターデバッグ機能
 **/
class DebugActor extends FlxSubState {

  // 背景のサイズ
  static inline var BG_WIDTH:Int = 128;
  static inline var BG_HEIGHT:Int = TEXT_DY * (14 + 2);

  // テキストの座標
  static inline var TEXT_X:Int = 16;
  static inline var TEXT_Y:Int = 16;
  static inline var TEXT_DY:Int = 12;

  // カーソルの位置に対応する項目
  static inline var ITEM_ID:Int    = 0;
  static inline var ITEM_NAME:Int  = 1;
  static inline var ITEM_GROUP:Int = 2;
  static inline var ITEM_HP:Int    = 3;
  static inline var ITEM_BST:Int   = 4;
  static inline var ITEM_STR:Int   = 5;
  static inline var ITEM_VIT:Int   = 6;
  static inline var ITEM_AGI:Int   = 7;
  static inline var ITEM_MAG:Int   = 8;
  static inline var ITEM_XP:Int    = 9;
  static inline var ITEM_MONEY:Int = 10;
  static inline var ITEM_BUFF_ATK:Int = 11;
  static inline var ITEM_BUFF_DEF:Int = 12;
  static inline var ITEM_BUFF_SPD:Int = 13;

  // 開始番号
  static inline var ITEM_FIRST:Int = ITEM_ID;
  // 終端番号
  static inline var ITEM_LAST:Int  = ITEM_BUFF_SPD;

  // ページ情報
  var _nPage:Int;
  var _nPageMax:Int;
  var _txtPage:FlxText;

  var _actorList:Array<Actor>;

  // 表示中のActor
  var _actor:Actor;

  // カーソル
  var _txtCursor:FlxText;
  var _cursor:Int;

  var _txtID:FlxText;    // ID
  var _txtName:FlxText;  // 名前
  var _txtGroup:FlxText; // 所属グループ
  var _txtHp:FlxText;    // HP
  var _txtBst:FlxText;   // バッドステータス
  var _txtStr:FlxText;   // 力
  var _txtVit:FlxText;   // 耐久力
  var _txtAgi:FlxText;   // 素早さ
  var _txtMag:FlxText;   // 魔力
  var _txtXp:FlxText;    // 経験値
  var _txtMoney:FlxText; // 所持金
  var _txtBuffAtk:FlxText; // バフ・攻撃力
  var _txtBuffDef:FlxText; // バフ・守備力
  var _txtBuffSpd:FlxText; // バフ・素早さ

  /**
   * 生成
   **/
  override public function create() {
    super.create();

    var bg = new FlxSprite().makeGraphic(BG_WIDTH, BG_HEIGHT, FlxColor.BLACK);
    bg.alpha = 0.8;
    this.add(bg);

    // ページ番号
    _txtPage = new FlxText(0, 0);
    _txtPage.color = FlxColor.SILVER;
    this.add(_txtPage);

    _actor = null;

    // カーソル
    _txtCursor = new FlxText(TEXT_X-12, TEXT_Y, 32, ">");
    this.add(_txtCursor);
    _cursor = ITEM_HP;

    // 項目テキスト
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
    _txtBst = new FlxText(px, py);
    txtList.add(_txtBst);
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
    _txtMag = new FlxText(px, py);
    txtList.add(_txtMag);
    py += TEXT_DY;
    _txtXp = new FlxText(px, py);
    txtList.add(_txtXp);
    py += TEXT_DY;
    _txtMoney = new FlxText(px, py);
    txtList.add(_txtMoney);
    py += TEXT_DY;
    _txtBuffAtk = new FlxText(px, py);
    txtList.add(_txtBuffAtk);
    py += TEXT_DY;
    _txtBuffDef = new FlxText(px, py);
    txtList.add(_txtBuffDef);
    py += TEXT_DY;
    _txtBuffSpd = new FlxText(px, py);
    txtList.add(_txtBuffSpd);
    py += TEXT_DY;

    for(txt in txtList) {
      this.add(txt);
    }

    _nPage = 0;
    _actorList = ActorMgr.getAlive();
    _nPageMax = _actorList.length;

    _setText(_nPage);
  }

  /**
   * テキストを設定
   **/
  private function _setText(idx:Int):Void {
    _txtPage.text = 'page(${idx}/${_nPageMax-1})';

    var act = _actorList[idx];
    _actor = act;

    _txtID.text    = 'ID: ${act.ID}';
    _txtName.text  = ${act.name};
    _txtGroup.text = 'Grp: ${act.group}';
    _txtHp.text    = 'HP: ${act.hp}/${act.hpmax}';
    _txtBst.text   = '${act.badstatus} (${act.badstatusTurn})';
    _txtStr.text   = 'STR: ${act.str}';
    _txtVit.text   = 'VIT: ${act.vit}';
    _txtAgi.text   = 'AGI: ${act.agi}';
    _txtMag.text   = 'MAG: ${act.mag}';
    _txtXp.text    = 'XP: ${act.xp}';
    _txtMoney.text = 'MONEY: ${act.money}';
    _txtBuffAtk.text = 'BUFF ATK: ${act.buffAtk}';
    _txtBuffDef.text = 'BUFF DEF: ${act.buffDef}';
    _txtBuffSpd.text = 'BUFF SPD: ${act.buffSpd}';
  }

  /**
   * カーソルの位置が変更できる項目かどうかをチェック
   **/
  private function _checkCursor():Bool {
    switch(_cursor) {
      case ITEM_ID, ITEM_NAME, ITEM_GROUP:
        // 変更できない
        return false;
      default:
        // 変更できる
        return true;
    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(FlxG.keys.justPressed.Q) {
      // 閉じる
      close();
      return;
    }

    if(Input.on.B) {
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
    else {
      // 項目の移動
      _moveCursor();

      // 項目の編集
      _editItem();
    }

    // カーソル位置の更新
    _txtCursor.y = TEXT_Y + (TEXT_DY * _cursor);
  }

  private function _moveCursor():Void {
    if(Input.press.UP) {
      // 上に移動
      _cursor--;
      if(_cursor < ITEM_FIRST) {
        _cursor = ITEM_LAST;
      }
      while(_checkCursor() == false) {
        _cursor--;
        if(_cursor < ITEM_FIRST) {
          _cursor = ITEM_LAST;
        }
      }
    }
    if(Input.press.DOWN) {
      // 下に移動
      _cursor++;
      if(_cursor > ITEM_LAST) {
        _cursor = ITEM_FIRST;
      }
      while(_checkCursor() == false) {
        _cursor++;
        if(_cursor > ITEM_LAST) {
          _cursor = ITEM_FIRST;
        }
      }
    }
  }

  private function _editItem():Void {
    var val = 1;
    if(Input.on.X) {
      val *= 10;
    }
    if(Input.on.Y) {
      val *= 100;
    }

    if(Input.press.LEFT) {
      val *= -1;
    }
    else if(Input.press.RIGHT) {
    }
    else {
      // 編集していない
      return;
    }
    switch(_cursor) {
      case ITEM_HP:
        _actor.param.hp    += val;
        _actor.param.hpmax += val;
      case ITEM_BST:
        var bst = _actor.badstatus;
        var next = BadStatusUtil.next(bst);
        if(val < 0) {
          next = BadStatusUtil.prev(bst);
        }
        _actor.adhereBadStatus(next, true);
      case ITEM_STR:
        _actor.param.str += val;
      case ITEM_VIT:
        _actor.param.vit += val;
      case ITEM_AGI:
        _actor.param.agi += val;
      case ITEM_MAG:
        _actor.param.mag += val;
      case ITEM_XP:
        _actor.param.xp += val;
      case ITEM_MONEY:
        _actor.param.money += val;
      case ITEM_BUFF_ATK:
        _actor.param.buffAtk += val;
      case ITEM_BUFF_DEF:
        _actor.param.buffDef += val;
      case ITEM_BUFF_SPD:
        _actor.param.buffSpd += val;
    }

    // テキスト更新
    _setText(_nPage);
  }
}
