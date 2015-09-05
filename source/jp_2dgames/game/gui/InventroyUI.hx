package jp_2dgames.game.gui;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.Inventory;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * インベントリUI
 **/
class InventroyUI extends FlxSpriteGroup {

  // ■定数
  public static inline var CMD_CANCEL:Int = -1;

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
   * @param cbFunc アイテム選択コールバック
   **/
  public function new(cbFunc:Int->Void) {

    // 基準座標を設定
    {
      var px = BASE_X;
      var py = FlxG.height + BASE_OFS_Y;
      super(px, py);
    }

    // コマンドボタンの配置
    var btnList = new List<MyButton>();
    var idx = 0;
    for(item in Inventory.getItemList()) {
      var px = BTN_X + BTN_DX * (idx%3);
      var py = BTN_Y + BTN_DY * Math.floor(idx/3);
      var name = ItemUtil.getName(item);
      btnList.add(new MyButton(px, py, name, function() {
        cbFunc(idx);
      }));
      idx++;
    }

    // キャンセルボタン
    var px = BTN_X + BTN_DX*2;
    var py = BTN_Y + BTN_DY*2;
    btnList.add(new MyButton(px, py, "CANCEL", function() {
      cbFunc(CMD_CANCEL);
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
