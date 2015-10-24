package jp_2dgames.game.gui;
import flixel.util.FlxAngle;
import flixel.util.FlxColorUtil;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import jp_2dgames.game.particle.ParticleDamage;
import jp_2dgames.game.actor.ActorMgr;
import flixel.util.FlxColor;
import jp_2dgames.lib.StatusBar;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * バトル用キャラステータスUI
 **/
class BtlCharaUI extends FlxSpriteGroup {

  // ■定数
  // 揺れ時間
  static inline var TIMER_SHAKE:Int = 120;
  // 背景枠の色変化の時間
  static inline var TIMER_BG_COLOR:Int = 45;

  // 全体のサイズ
  public static inline var WIDTH  = 80;
  public static inline var HEIGHT = 32;

  // 背景の描画座標・サイズ
  public static inline var BG_MERGIN = 2;
  /// レベル
  public static inline var BG_LV_OFS_X  = BG_MERGIN;
  public static inline var BG_LV_OFS_Y  = BG_MERGIN;
  public static inline var BG_LV_WIDTH  = 16;
  public static inline var BG_LV_HEIGHT = 16;
  /// 名前
  public static inline var BG_NAME_OFS_X  = (BG_MERGIN*2) + BG_LV_WIDTH;
  public static inline var BG_NAME_OFS_Y  = BG_LV_OFS_Y;
  public static inline var BG_NAME_WIDTH  = WIDTH - BG_NAME_OFS_X - BG_MERGIN;
  public static inline var BG_NAME_HEIGHT = BG_LV_HEIGHT;
  /// HP/MP
  public static inline var BG_HPMP_OFS_X  = BG_MERGIN;
  public static inline var BG_HPMP_OFS_Y  = (BG_MERGIN*2) + BG_LV_HEIGHT;
  public static inline var BG_HPMP_WIDTH  = WIDTH - (BG_MERGIN*2);
  public static inline var BG_HPMP_HEIGHT = HEIGHT - BG_HPMP_OFS_Y - BG_MERGIN;

  // フォントの描画座標・サイズ
  /// Lvラベル
  public static inline var TXT_LV_LABEL_OFS_X = BG_MERGIN;
  public static inline var TXT_LV_LABEL_OFS_Y = BG_MERGIN;
  public static inline var TXT_LV_LABEL_SIZE  = 4;
  /// Lv数値
  public static inline var TXT_LV_OFS_X = BG_MERGIN;
  public static inline var TXT_LV_OFS_Y = TXT_LV_LABEL_OFS_Y + 4;
  public static inline var TXT_LV_SIZE  = 8;
  public static inline var TXT_LV_WIDTH = BG_LV_WIDTH;
  /// 名前
  public static inline var TXT_NAME_OFS_X = BG_NAME_OFS_X + 2;
  public static inline var TXT_NAME_OFS_Y = BG_NAME_OFS_Y + 1;

  /// HPラベル
  public static inline var TXT_HP_LABEL_OFS_X = BG_HPMP_OFS_X;
  public static inline var TXT_HP_LABEL_OFS_Y = BG_HPMP_OFS_Y-2;
  public static inline var TXT_HPMP_LABEL_SIZE  = 5;
  /// HP数値
  public static inline var TXT_HPMP_NUM_DX = 12;
  public static inline var TXT_HP_OFS_X = TXT_HP_LABEL_OFS_X + TXT_HPMP_NUM_DX;
  public static inline var TXT_HP_OFS_Y = TXT_HP_LABEL_OFS_Y;
  public static inline var TXT_HPMP_WIDTH = TXT_HPMP_SIZE*3;
  public static inline var TXT_HPMP_SIZE = 8;

  /// MPラベル
  public static inline var TXT_MP_LABEL_OFS_X = TXT_HP_OFS_X + TXT_HPMP_WIDTH;
  public static inline var TXT_MP_LABEL_OFS_Y = TXT_HP_LABEL_OFS_Y;
  /// MP数値
  public static inline var TXT_MP_OFS_X = TXT_MP_LABEL_OFS_X+ TXT_HPMP_NUM_DX;
  public static inline var TXT_MP_OFS_Y = TXT_HP_LABEL_OFS_Y;

  // HP/MPバー
  public static inline var BAR_HP_X   = TXT_HP_LABEL_OFS_X + 2;
  public static inline var BAR_MP_X   = TXT_MP_LABEL_OFS_X + 2;
  public static inline var BAR_HPMP_Y = TXT_HP_LABEL_OFS_Y + 10;
  public static inline var BAR_HPMP_WIDTH  = 32;
  public static inline var BAR_HPMP_HEIGHT = 2;

  // バステアイコン
  public static inline var BST_X = 0;
  public static inline var BST_Y = HEIGHT;


  // ■メンバ変数
  var _xstart:Float = 0;
  var _ystart:Float = 0;

  // アニメーションタイマー
  var _tAnime:Int = 0;

  // ダメージ時の揺れ
  var _tShake:Float = 0;

  // 変化させた枠の色
  var _bgColor:Int = MyColor.PANEL_NON_ACTIVE;
  // 変化させた枠の色のタイマー
  var _tBgColor:Int = 0;

  // 背景枠
  var _bg:FlxSprite;
  // レベル背景
  var _bgLv:FlxSprite;
  // 名前背景
  var _bgName:FlxSprite;
  // HP/MP背景
  var _bgHpMp:FlxSprite;

  // レベル
  var _txtLvCaption:FlxText;
  // レベル(数値)
  var _txtLv:FlxText;
  // 名前
  var _txtName:FlxText;
  // バステアイコン
  var _icon:BadStatusUI;

  // HPラベル
  var _txtHpLabel:FlxText;
  // HP数値
  var _txtHp:FlxText;
  // HPゲージ
  var _barHp:HpBar;
  // MPラベル
  var _txtMpLabel:FlxText;
  // MP数値
  var _txtMp:FlxText;
  // MPゲージ
  var _barMp:StatusBar;

  // 表示するActorのID
  var _actorID:Int = 0;
  public var actorID(get, never):Int;
  private function get_actorID() {
    return _actorID;
  }

  // Actor
  var _actor:Actor = null;

  // 中心座標
  public var xcenter(get, never):Float;
  private function get_xcenter() {
    return _xstart + WIDTH/2;
  }
  public var ycenter(get, never):Float;
  private function get_ycenter() {
    return _ystart + HEIGHT/2;
  }

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float, actor:Actor=null) {
    super(X, Y);
    _xstart = X;
    _ystart = Y;
    _actor  = actor;

    // 背景
    _bg = new FlxSprite(0, 0).makeGraphic(WIDTH, HEIGHT, FlxColor.WHITE);
    _bg.color = MyColor.PANEL_NON_ACTIVE;
    this.add(_bg);

    // レベル背景
    _bgLv = new FlxSprite(BG_LV_OFS_X, BG_LV_OFS_Y);
    _bgLv.makeGraphic(BG_LV_WIDTH, BG_LV_HEIGHT, FlxColor.AZURE);
    this.add(_bgLv);

    // 名前背景
    _bgName = new FlxSprite(BG_NAME_OFS_X, BG_NAME_OFS_Y);
    _bgName.makeGraphic(BG_NAME_WIDTH, BG_NAME_HEIGHT, FlxColor.AZURE);
    this.add(_bgName);

    // HPMP背景
    _bgHpMp = new FlxSprite(BG_HPMP_OFS_X, BG_HPMP_OFS_Y);
    _bgHpMp.makeGraphic(BG_HPMP_WIDTH, BG_HPMP_HEIGHT, FlxColor.WHITE);
    _bgHpMp.color = FlxColor.NAVY_BLUE;
    this.add(_bgHpMp);

    // ■テキスト
    // Lvラベル
    _txtLvCaption = new FlxText(TXT_LV_LABEL_OFS_X, TXT_LV_LABEL_OFS_Y, 64, TXT_LV_LABEL_SIZE);
    _txtLvCaption.text = "Lv";
    _txtLvCaption.color = FlxColor.BLACK;
    this.add(_txtLvCaption);
    // Lv数値
    _txtLv = new FlxText(TXT_LV_OFS_X, TXT_LV_OFS_Y, TXT_LV_WIDTH, TXT_LV_SIZE);
    _txtLv.alignment = "right";
    this.add(_txtLv);

    // 名前
    _txtName = new FlxText(TXT_NAME_OFS_X, TXT_NAME_OFS_Y);
    _txtName.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtName);

    // HPラベル
    _txtHpLabel = new FlxText(TXT_HP_LABEL_OFS_X, TXT_HP_LABEL_OFS_Y, 64, TXT_HPMP_LABEL_SIZE);
    _txtHpLabel.text = "HP";
    _txtHpLabel.color = FlxColor.CORAL;
    this.add(_txtHpLabel);
    // HPゲージ
    _barHp = new HpBar(BAR_HP_X, BAR_HPMP_Y, BAR_HPMP_WIDTH, BAR_HPMP_HEIGHT);
    this.add(_barHp);
    // HP数値
    _txtHp = new FlxText(TXT_HP_OFS_X, TXT_HP_OFS_Y, TXT_HPMP_WIDTH, TXT_HPMP_SIZE);
    _txtHp.alignment = "right";
    this.add(_txtHp);

    // MPラベル
    _txtMpLabel = new FlxText(TXT_MP_LABEL_OFS_X, TXT_MP_LABEL_OFS_Y, 64, TXT_HPMP_LABEL_SIZE);
    _txtMpLabel.text = "TP";
    _txtMpLabel.color = FlxColor.LIME;
    this.add(_txtMpLabel);
    // MPゲージ
    _barMp = new StatusBar(BAR_MP_X, BAR_HPMP_Y, BAR_HPMP_WIDTH, BAR_HPMP_HEIGHT);
    _barMp.createGradientBar([FlxColor.CHARCOAL, FlxColor.CHARCOAL], [FlxColor.LIME, FlxColor.FOREST_GREEN], 2);
    this.add(_barMp);
    // MP数値
    _txtMp = new FlxText(TXT_MP_OFS_X, TXT_MP_OFS_Y, TXT_HPMP_WIDTH, TXT_HPMP_SIZE);
    _txtMp.alignment = "right";
    this.add(_txtMp);

    // バステアイコン
    _icon = new BadStatusUI(BST_X, BST_Y);
    _icon.set(BadStatus.None);
    this.add(_icon);
  }

  /**
   * 表示するActorを設定する
   **/
  public function setActorID(actorID:Int):Void {
    _actorID = actorID;
    for(obj in members) {
      // スクロール無効
      obj.scrollFactor.set(0, 0);
    }
  }

  /**
   * 背景枠の色を変化する
   **/
  private function _changeBgColor(c:Int):Void {
    _tBgColor = TIMER_BG_COLOR;
    _bgColor = c;
  }

  /**
   * ダメージ
   **/
  public function damage():Void {

    // 枠を赤くする
    _changeBgColor(MyColor.PANEL_DAMAGE);
  }

  /**
   * ミス
   **/
  public function miss():Void {
    var px = xcenter;
    var py = ycenter;
    // ダメージ数値
    var p = ParticleDamage.start(px, py, -1);
    // スクロール無効
    p.scrollFactor.set(0, 0);
    p.color = MyColor.NUM_MISS;
  }

  /**
   * アクティブ状態の設定
   **/
  public function setActive(b:Bool):Void {
    if(b) {
      // アクティブ
      _bg.color = MyColor.PANEL_ACTIVE;
    }
    else {
      // 非アクティブ
      _bg.color = MyColor.PANEL_NON_ACTIVE;
    }
    _tBgColor = 0;
  }

  /**
   * Actorを取得する
   **/
  private function _getActor():Actor {
    if(_actor != null) {
      // Actorのポインタを使う
      return _actor;
    }
    // ActorIDから取得
    return ActorMgr.searchAll(_actorID);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _tAnime++;

    // 揺れ更新
    _updateShake();

    // 枠の色更新
    _updateBgColor();

    var actor = _getActor();
    if(actor == null) {
      return;
    }

    _txtLv.text   = '${actor.lv}';
    _txtName.text = actor.name;
    _txtHp.text   = '${actor.hp}';
    _barHp.setPercent(100 * actor.hpratio);
    _txtMp.text   = '${actor.mp}';
    _barMp.setPercent(100 * actor.mpratio);

    // 危険状態の判定
    _updateDanger(actor);

    // バステアイコン更新
    _icon.set(actor.badstatus);

  }

  /**
   * 危険状態の更新
   **/
  private function _updateDanger(actor:Actor):Void {
    var col1:Int = FlxColor.NAVY_BLUE;
    var col2:Int = FlxColor.NAVY_BLUE;
    switch(actor.getDanger()) {
      case Actor.HP_WARN:
        col2 = FlxColor.GOLDEN;
      case Actor.HP_DANGER:
        col2 = FlxColor.RED;
      default:
        // アニメーション不要
        _bgHpMp.color = col1;
        return;
    }

    var cycle:Int = 60;
    var rad = (Std.int(_tAnime) % 180) * FlxAngle.TO_RAD;
    var t = 0.3 * Math.sin(rad);
    _bgHpMp.color = FlxColorUtil.darken(col2, t);
  }

  /**
   * 揺らす
   **/
  private function _updateShake():Void {
    if(_tShake > 0) {
      _tShake *= 0.9;
      if(_tShake < 1) {
        _tShake = 0;
      }
      var xsign = if(_tAnime%4 < 2) 1 else -1;
      x = _xstart + (_tShake * xsign * 0.2);
    }
  }

  /**
   * 枠の色
   **/
  private function _updateBgColor():Void {
    if(_tBgColor > 0) {
      _tBgColor--;
      _bg.color = _bgColor;
//      _bg.color = FlxColorUtil.interpolateColor(_bgColor, MyColor.PANEL_NON_ACTIVE, TIMER_BG_COLOR, (TIMER_BG_COLOR - _tBgColor));
      if(_tBgColor == 0) {
        _bg.color = MyColor.PANEL_NON_ACTIVE;
      }
    }
  }

  /**
   * ダメージの揺れ開始
   **/
  public function shake():Void {
    _tShake = TIMER_SHAKE;
  }
}
