package jp_2dgames.game;
import jp_2dgames.game.BtlCmdUtil.BtlCmd;
import jp_2dgames.game.actor.Actor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * バトルコマンドUI
 **/
class BtlCmdUI extends FlxSpriteGroup {

  // ■定数
  // 選択したコマンド
  public static inline var CMD_ATK1:Int   = 0; // 攻撃1
  public static inline var CMD_ATK2:Int   = 1; // 攻撃2
  public static inline var CMD_ATK3:Int   = 2; // 攻撃3
  public static inline var CMD_ITEM:Int   = 3; // アイテム
  public static inline var CMD_ESCAPE:Int = 4; // 逃げる

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
   * @param actor 行動主体者
   * @param cbFunc コマンド実行コールバック関数
   **/
  public function new(actor:Actor, cbFunc:Actor->BtlCmd->Void) {

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
      cbFunc(actor, BtlCmd.Attack(0));
    }));
    px += BTN_DX;
    btnList.add(new MyButton(px, py, "ATTACK2", function() {
      cbFunc(actor, BtlCmd.Attack(1));
    }));
    px += BTN_DX;
    btnList.add(new MyButton(px, py, "ATTACK3", function() {
      cbFunc(actor, BtlCmd.Attack(2));
    }));

    // 2列目
    px = BTN_X;
    py += BTN_DY;
    btnList.add(new MyButton(px, py, "ITEM", function() {
      cbFunc(actor, BtlCmd.Item(0));
    }));
    px += BTN_DX;
    btnList.add(new MyButton(px, py, "ESCAPE", function() {
      cbFunc(actor, BtlCmd.Escape);
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
