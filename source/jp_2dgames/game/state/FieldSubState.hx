package jp_2dgames.game.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.gui.UIMsg;
import jp_2dgames.game.gui.BtlUI;
import jp_2dgames.game.gui.BtlCharaUI;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.Actor;

/**
 * フィールドのサブメニュー
 **/
class FieldSubState extends FlxSubState {

  // メニュー管理
  var _group:FlxSpriteGroup;

  // Actor情報
  var _actor:Actor;

  // メニューを閉じたときに実行する関数
  var _cbClose:Void->Void;

  // アイテムボタン
  var _btnItem:MyButton;

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

    // 黒色の背景
    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.CHARCOAL);
    bg.alpha = 0;
    bg.scrollFactor.set();
    this.add(bg);
    FlxTween.tween(bg, {alpha:0.7}, 1, {ease:FlxEase.expoOut});

    // Actor情報を生成
    _actor = new Actor(0);
    _actor.init(BtlGroup.Player, Global.getPlayerParam());
    _actor.setName(Global.getPlayerName());

    // メニューグループ
    {
      var px = InventoryUI.BASE_X;
      var py = FlxG.height + InventoryUI.BASE_OFS_Y;
      _group = new FlxSpriteGroup(px, py);
      this.add(_group);
    }

    // 各ボタンを配置
    _displayButton();

    // UI表示
    var charUI = new BtlCharaUI(0, BtlUI.CHARA_Y, _actor);
    this.add(charUI);

    _appearBtn();
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

    // アイテムボタン
    {
      _btnItem = _addItemButton(px, py);
      _group.add(_btnItem);
    }

    py += InventoryUI.BTN_DY;
    {
      // 他にボタンを追加する場合はここに追加
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

  /**
   * アイテムボタンを配置
   **/
  private function _addItemButton(px:Float, py:Float):MyButton {
    var btn:MyButton = null;

    var cbFunc = function(btnID:Int) {
      if(btnID != InventoryUI.CMD_CANCEL) {

        // アイテムを使う
        var item = Inventory.getItem(btnID);
        ItemUtil.use(_actor, item, false);
        Inventory.delItem(btnID);

        // プレイヤーパラメータをグローバルに戻しておく
        Global.setPlayerParam(_actor.param);
      }

      // 終了時のコールバック呼び出し
      _appearBtn();
    };

    var label = UIMsg.get(UIMsg.CMD_ITEM);
    btn = new MyButton(px, py, label, function() {
      // インベントリを開く
      InventoryUI.open(this, cbFunc, _actor);
      // メニュー非表示
      _group.visible = false;
    });

    return btn;
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

    // アイテムボタンを押せるかどうかチェック
    _btnItem.enable = (Inventory.isEmpty() == false);
  }
}
