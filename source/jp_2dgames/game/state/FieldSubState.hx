package jp_2dgames.game.state;

import jp_2dgames.game.gui.BtlUI;
import jp_2dgames.game.gui.BtlCharaUI;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.Actor;

/**
 * フィールドのサブメニュー
 **/
class FieldSubState extends FlxSubState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 黒色の背景
    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.CHARCOAL);
    bg.alpha = 0;
    bg.scrollFactor.set();
    this.add(bg);
    FlxTween.tween(bg, {alpha:0.7}, 1, {ease:FlxEase.expoOut});

    var actor = new Actor(0);
    actor.init(BtlGroup.Player, Global.getPlayerParam());
    actor.setName(Global.getPlayerName());
    var cbFunc = function(btnID:Int) {
      if(btnID != InventoryUI.CMD_CANCEL) {
        // アイテムを使う
        var item = Inventory.getItem(btnID);
        ItemUtil.use(actor, item, true);
        Inventory.delItem(btnID);
        // プレイヤーパラメータをグローバルに戻しておく
        Global.setPlayerParam(actor.param);
      }
      // おしまい
      close();
    };

    // UI表示
    var charUI = new BtlCharaUI(0, BtlUI.CHARA_Y, actor);
    this.add(charUI);

    // インベントリを開く
    InventoryUI.open(this, cbFunc, actor);
  }

  /**
   * 破棄
   */
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();
  }
}
