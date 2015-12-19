package jp_2dgames.game.gui;

import jp_2dgames.game.gui.message.UIMsg;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.item.ItemData;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * 装備品UI
 **/
class EquipUI extends FlxSpriteGroup {

  // ■定数

  // 座標
  private static inline var BASE_X = 4;
  private static inline var BASE_Y = 120;

  // ウィンドウサイズ
  private static inline var WIDTH = 120 - 4*2;
  private static inline var HEIGHT = 80;

  // テキスト
  private static inline var TEXT_X = 4;
  private static inline var TEXT_Y = 4;
  private static inline var TEXT_DY = 12;
  private static inline var TEXT_WIDTH:Int = 128;

  // ■メンバ変数
  private var _txtAttack:FlxText;
  private var _txtDefense:FlxText;

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

    var txtList = new List<FlxText>();
    var px = TEXT_X;
    var py = TEXT_Y;
    _txtAttack = new FlxText(px, py, TEXT_WIDTH);
    txtList.add(_txtAttack);
    py += TEXT_DY;
    _txtDefense = new FlxText(px, py, TEXT_WIDTH);
    txtList.add(_txtDefense);
    py += TEXT_DY;

    for(txt in txtList) {
      txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
      this.add(txt);
    }

    // テキスト設定
    setText();

    for(obj in members) {
      obj.scrollFactor.set(0, 0);
    }
  }

  /**
   * テキストを設定する
   **/
  public function setText(item:ItemData=null):Void {

    var atk = 0;
    var def = 0;

    var weapon = Inventory.getWeapon();
    var armor  = Inventory.getArmor();
    if(weapon.id != ItemUtil.NONE) {
      atk = ItemUtil.getAtk(weapon);
    }
    if(armor.id != ItemUtil.NONE) {
      def = ItemUtil.getDef(armor);
    }

    var strAtk = UIMsg.get(UIMsg.ATTACK);
    var strDef = UIMsg.get(UIMsg.DEFENSE);
    _txtAttack.text  = '${strAtk}: ${atk}';
    _txtDefense.text = '${strDef}: ${def}';
  }
}
