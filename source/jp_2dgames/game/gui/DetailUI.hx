package jp_2dgames.game.gui;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * アイテム詳細UI
 **/
class DetailUI extends FlxSpriteGroup {

  // ■定数

  // 座標
  private static inline var BASE_X = 120 + 4;
  private static inline var BASE_Y = 120;

  // ウィンドウサイズ
  private static inline var WIDTH = 120 - 4*2;
  private static inline var HEIGHT = 80;

  // テキスト
  private static inline var TEXT_X = 4;
  private static inline var TEXT_Y = 4;
  private static inline var TEXT_DY = 12;
  private static inline var TEXT_WIDTH = 104;

  // ■メンバ変数
  private var _txtDetail:FlxText;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(BASE_X, BASE_Y);

    // 背景
    var bg = new FlxSprite();
    bg.makeGraphic(WIDTH, HEIGHT, FlxColor.BLACK);
    bg.alpha = 0.7;
    this.add(bg);

    _txtDetail = new FlxText(TEXT_X, TEXT_Y, TEXT_WIDTH);
    _txtDetail.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtDetail);

    for(obj in members) {
      obj.scrollFactor.set(0, 0);
    }
  }

  /**
   * テキストを設定する
   **/
  public function setText(item:ItemData):Void {
    var detail = ItemUtil.getDetail(item);
    _txtDetail.text = detail;
  }
}
