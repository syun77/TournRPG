package jp_2dgames.game.state;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import jp_2dgames.game.gui.UIMsg;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.lib.Input;
import flixel.FlxSubState;

/**
 * ショップ画面
 **/
class ShopState extends FlxSubState {

  // 終了時のコールバック
  var _cbClose:Void->Void;

  // ■各種UI
  var _group:FlxSpriteGroup;

  /**
   * コンストラクタ
   **/
  public function new(cbClose:Void->Void) {
    super();

    _cbClose = cbClose;
  }

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // メニューグループ
    {
      var px = InventoryUI.BASE_X;
      var py = FlxG.height + InventoryUI.BASE_OFS_Y;
      _group = new FlxSpriteGroup(px, py);
      this.add(_group);
    }

    // 各ボタンを配置
    _displayButton();

    _appearBtn();
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    super.destroy();
  }

  /**
   * ボタンを出現させる
   **/
  private function _appearBtn():Void {
    _group.visible = true;
    var py = FlxG.height + InventoryUI.BASE_OFS_Y;
    _group.y = FlxG.height;
    FlxTween.tween(_group, {y:py}, 0.5, {ease:FlxEase.expoOut});
  }

  /**
   * 各ボタンを配置
   **/
  private function _displayButton():Void {
    var px = InventoryUI.BTN_X;
    var py = InventoryUI.BTN_Y;

    // 購入ボタン
    {
      var btn = _addBuyButton(px, py);
      _group.add(btn);
    }

    px += InventoryUI.BTN_DX;
    // 売却ボタン
    {
      var btn = _addSellButton(px, py);
      _group.add(btn);
    }

    // キャンセルボタン
    {
      var px = InventoryUI.BTN_CANCEL_X;
      var py = InventoryUI.BTN_CANCEL_Y;
      var label = UIMsg.get(UIMsg.CANCEL);
      var btn = new MyButton(px, py, label, function() {
        // UIを閉じる
        close();
        // 終了コールバック実行
        _cbClose();
      });
      btn.color       = MyColor.BTN_CANCEL;
      btn.label.color = MyColor.BTN_CANCEL_LABEL;
      _group.add(btn);
    }
  }

  private function _addBuyButton(px:Float, py:Float):MyButton {

    var label = UIMsg.get(UIMsg.SHOP_BUY);
    var btn = new MyButton(px, py, label, function() {
      // メニュー非表示
      //_group.visible = false;
    });

    return btn;
  }

  private function _addSellButton(px:Float, py:Float):MyButton {

    var label = UIMsg.get(UIMsg.SHOP_SELL);
    var btn = new MyButton(px, py, label, function() {
      // メニュー非表示
      //_group.visible = false;
    });

    return btn;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(Input.press.B) {
      // TODO: 閉じる
      close();
    }
  }
}
