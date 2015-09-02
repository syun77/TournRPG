package jp_2dgames.game;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * バトルコマンドUI
 **/
class BtlCmdUI extends FlxSpriteGroup {

  // ■定数
  public static inline var CMD_ATK1:Int = 0; // 攻撃1を選択
  public static inline var CMD_ATK2:Int = 1; // 攻撃2を選択
  public static inline var CMD_ATK3:Int = 2; // 攻撃3を選択
  public static inline var CMD_ITEM:Int = 3; // アイテムを選択

  // 座標
  private static inline var BASE_X = 0;
  private static inline var BASE_OFS_Y = -64;

  // ボタン
  private static inline var BTN_X = 0;
  private static inline var BTN_Y = 0;
  private static inline var BTN_DX = 80;
  private static inline var BTN_DY = 24;

  // ■メンバ変数

  /**
   * コンストラクタ
   **/
  public function new(_cbFunc:Int->Void) {

    // 基準座標を設定
    {
      var px = BASE_X;
      var py = FlxG.height + BASE_OFS_Y;
      super(px, py);
    }

    // コマンドボタンの配置
    var btnList = new List<MyButton>();
    var px = BTN_X;
    var py = BTN_Y;
    btnList.add(new MyButton(px, py, "ATTACK1", function() {
      _cbFunc(CMD_ATK1);
    }));
    px += BTN_DX;
    btnList.add(new MyButton(px, py, "ATTACK2", function() {
      _cbFunc(CMD_ATK2);
    }));
    px += BTN_DX;
    btnList.add(new MyButton(px, py, "ATTACK3", function() {
      _cbFunc(CMD_ATK3);
    }));
    px += BTN_DX;
    btnList.add(new MyButton(px, py, "ATTACK3", function() {
      _cbFunc(CMD_ATK3);
    }));
    px = BTN_X;
    py += BTN_DY;
    btnList.add(new MyButton(px, py, "ITEM", function() {
      _cbFunc(CMD_ITEM);
    }));

    for(btn in btnList) {
      this.add(btn);
    }

    {
      var py2 = y;
      y = FlxG.height;
      FlxTween.tween(this, {y:py2}, 1, {ease:FlxEase.expoOut});
    }
  }
}
