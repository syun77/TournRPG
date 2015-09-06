package jp_2dgames.game.gui;
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
  // 座標
  private static inline var BASE_X = 0;
  private static inline var BASE_OFS_Y = -64;

  // ボタン
  private static inline var BTN_X = 0;
  private static inline var BTN_Y = 0;
  private static inline var BTN_DX = 80;
  private static inline var BTN_DY = 24;

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
      cbFunc(actor, BtlCmd.Item(btnID));
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
      // インベントリ表示
      _displayInventoryUI();
    }));
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
    FlxTween.tween(this, {y:py}, 1, {ease:FlxEase.expoOut});
  }

  /**
   * インベントリUIを表示する
   **/
  private function _displayInventoryUI():Void {
    _inventoryUI = new InventroyUI(_cbItemSelect);
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

    trace("btnID", btnID);
    // アイテムを選んだ
    _cbItem(btnID);
  }
}
