package jp_2dgames.game.gui;
import jp_2dgames.game.btl.BtlRange;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.btl.BtlCmdUtil;
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
  // 座標
  private static inline var BASE_X = 0;
  private static inline var BASE_OFS_Y = -(BTN_DY*3.5);

  // ボタン
  private static inline var BTN_X = 0;
  private static inline var BTN_Y = 0;
  private static inline var BTN_DX = MyButton.WIDTH;
  private static inline var BTN_DY = MyButton.HEIGHT + 2;

  // ■メンバ変数
  private var _inventoryUI:InventroyUI = null;
  private var _cbItem:Int->Void = null;

  /**
   * コンストラクタ
   * @param actor 行動主体者
   * @param cbFunc コマンド実行コールバック関数
   **/
  public function new(actor:Actor, cbFunc:Actor->BtlCmd->Void) {

    // アイテム選択のコール関数を登録しておく
    _cbItem = function(btnID:Int) {
      var item = Inventory.getItem(btnID);
      item.bReserved = true;
      // ここでは使うアイテムのみ登録
      cbFunc(actor, BtlCmd.Item(item, null, 0));
    };

    // 基準座標を設定
    {
      var px = BASE_X;
      super(px, 0);
    }

    // コマンドボタンの配置
    var btnList = new List<MyButton>();
    var px = BTN_X;
    var py = BTN_Y;
    btnList.add(new MyButton(px, py, "ATTACK1", function() {
      cbFunc(actor, BtlCmd.Attack(BtlRange.One, 0));
    }));
    px += BTN_DX;
    btnList.add(new MyButton(px, py, "ATTACK2", function() {
      cbFunc(actor, BtlCmd.Attack(BtlRange.One, 0));
    }));
    px += BTN_DX;
    btnList.add(new MyButton(px, py, "ATTACK3", function() {
      cbFunc(actor, BtlCmd.Attack(BtlRange.One, 0));
    }));

    // 2列目
    px = BTN_X;
    py += BTN_DY;
    var btnItem = new MyButton(px, py, "ITEM", function() {
      // インベントリ表示
      _displayInventoryUI(actor);
    });
    if(Inventory.isEmpty()) {
      // アイテムがないので選べない
      btnItem.enable = false;
    }
    btnList.add(btnItem);

    px += BTN_DX;
    btnList.add(new MyButton(px, py, "ESCAPE", function() {
      cbFunc(actor, BtlCmd.Escape);
    }));

    for(btn in btnList) {
      this.add(btn);
    }

    // 表示
    _display();
  }

  /**
   * 表示開始
   **/
  private function _display():Void {
    visible = true;
    var py = FlxG.height + BASE_OFS_Y;
    y = FlxG.height;
    FlxTween.tween(this, {y:py}, 0.5, {ease:FlxEase.expoOut});
  }

  /**
   * インベントリUIを表示する
   **/
  private function _displayInventoryUI(actor:Actor):Void {
    _inventoryUI = new InventroyUI(_cbItemSelect, actor);
    FlxG.state.add(_inventoryUI);
    // 自身は非表示
    visible = false;
  }

  /**
   * アイテム選択のコールバック関数
   **/
  private function _cbItemSelect(btnID:Int):Void {

    // アイテム選択UIを非表示
    FlxG.state.remove(_inventoryUI);
    _inventoryUI.kill();

    if(btnID == InventroyUI.CMD_CANCEL) {
      // キャンセルしたのでコマンドUIを再び表示
      _display();
      return;
    }

    // アイテムを選んだ
    _cbItem(btnID);
  }
}
