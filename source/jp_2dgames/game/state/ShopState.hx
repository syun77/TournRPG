package jp_2dgames.game.state;
import jp_2dgames.game.gui.MyButton2;
import jp_2dgames.lib.Snd;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.gui.SkillUI;
import jp_2dgames.game.gui.FieldUI;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.skill.SkillSlot;
import jp_2dgames.game.gui.ShopBuyUI;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.Inventory;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import jp_2dgames.game.gui.UIMsg;
import jp_2dgames.game.gui.InventoryUI;
import flixel.FlxSubState;

/**
 * ショップ画面
 **/
class ShopState extends FlxSubState {

  static inline var BG_OFS_Y:Int = 0;

  // 終了時のコールバック
  var _cbClose:Void->Void;

  // ■各種UI
  var _group:FlxSpriteGroup;

  // 背景
  var _bg:FlxSprite;

  // フィールドUI
  var _fieldUI:FieldUI;

  // アイテム売却ボタン
  var _btnItemSell:MyButton2;

  // スキル売却ボタン
  var _btnSkillSell:MyButton2;

  /**
   * コンストラクタ
   **/
  public function new(cbClose:Void->Void, fieldUI:FieldUI) {
    super();

    _cbClose = cbClose;
    _fieldUI = fieldUI;
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

    // 背景
    {
      var height = FlxG.height + InventoryUI.BASE_OFS_Y;
      _bg = new FlxSprite(0, BG_OFS_Y);
      _bg.loadGraphic(Reg.PATH_MENU_BG);
      _bg.alpha = 0.5;
      _group.add(_bg);
    }

    // 各ボタンを配置
    _displayButton();

    _appearBtn();

    // メッセージウィンドウ登録
    var csv = new CsvLoader(Reg.PATH_CSV_MESSAGE);
    Message.createInstancePush(csv, this);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Message.destroyInstance(this);

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

    // アイテムを所持していない場合は売却できない
    _btnItemSell.enabled = (Inventory.isEmpty() == false);
    // スキルを所持していない場合は売却できない
    _btnSkillSell.enabled = (SkillSlot.isEmpty() == false);
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
    // アイテム売却ボタン
    {
      _btnItemSell = _addItemSellButton(px, py);
      _group.add(_btnItemSell);
    }

    px += InventoryUI.BTN_DX;
    // スキル売却ボタン
    {
      _btnSkillSell = _addSkillSellButton(px, py);
      _group.add(_btnSkillSell);
    }
    // キャンセルボタン

    {
      var px = InventoryUI.BTN_CANCEL_X;
      var py = InventoryUI.BTN_CANCEL_Y;
      var label = UIMsg.get(UIMsg.CANCEL);
      var btn = new MyButton2(px, py, label, function() {
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
   * アイテム購入
   **/
  private function _buyItem(idx:Int, category:Int):Void {
    var shop = Global.getShopData();
    var money:Int = 0;
    var name:String = "";

    switch(category) {
      case ShopBuyUI.CATEGORY_ITEM:
        // ■消費アイテム
        var itemList = shop.itemList;
        var item = itemList[idx];
        // インベントリに追加
        Inventory.push(item);
        // お金を減らす
        money = ItemUtil.getBuy(item);
        Global.useMoney(money);
        // ショップから削除
        itemList.remove(item);
        // 名前を取得
        name = ItemUtil.getName(item);

      case ShopBuyUI.CATEGORY_EQUIP:
        // ■装備品
        var equipList = shop.equipList;
        var equip = equipList[idx];
        // インベントリに追加
        Inventory.push(equip);
        // お金を減らす
        money = ItemUtil.getBuy(equip);
        Global.useMoney(money);
        // ショップから削除
        equipList.remove(equip);
        // 名前を取得
        name = ItemUtil.getName(equip);

      case ShopBuyUI.CATEGORY_SKILL:
        // ■スキル
        var skillList = shop.skillList;
        var skill = skillList[idx];
        // スキルスロットに追加
        SkillSlot.addSkill(skill);
        // お金を減らす
        money = SkillUtil.getBuy(skill.id);
        Global.useMoney(money);
        // ショップから削除
        skillList.remove(skill);
        // 名前を取得
        name = SkillUtil.getName(skill.id);
    }

    // メッセージ表示　
    Message.push2(Msg.ITEM_BUY, [name, money]);

    Snd.playSe("coin", true);
  }

  /**
   * 購入ボタン
   **/
  private function _addBuyButton(px:Float, py:Float):MyButton2 {

    var cbFunc = function(btnID:Int, category:Int) {

      if(btnID != ShopBuyUI.BTN_ID_CANCEL) {
        // アイテム購入
        _buyItem(btnID, category);
      }

      // ボタン出現
      _appearBtn();
    }

    var label = UIMsg.get(UIMsg.SHOP_BUY);
    var btn = new MyButton2(px, py, label, function() {
      // 購入メニューを開く
      ShopBuyUI.open(this, cbFunc, null);
      // メニュー非表示
      _group.visible = false;
    });

    return btn;
  }

  /**
   * アイテム売却ボタン
   **/
  private function _addItemSellButton(px:Float, py:Float):MyButton2 {

    var cbFunc = function(btnID:Int) {
      if(btnID != InventoryUI.CMD_CANCEL) {
        // アイテム売却
        var item = Inventory.getItem(btnID);
        // お金に換算
        var money = ItemUtil.getSell(item);
        Global.addMoney(money);
        // アイテム削除
        Inventory.delItem(btnID);
        // 名前
        var name = ItemUtil.getName(item);
        // メッセージ表示
        Message.push2(Msg.ITEM_SELL, [name, money]);
        Snd.playSe("coin", true);
      }

      // ボタン出現
      _appearBtn();
    }

    var label = UIMsg.get(UIMsg.SHOP_ITEM_SELL);
    var btn = new MyButton2(px, py, label, function() {
      // インベントリを開く
      InventoryUI.open(this, cbFunc, null, InventoryUI.MODE_SELL);
      // メニュー非表示
      _group.visible = false;
    });

    return btn;
  }

  /**
   * スキル売却
   **/
  private function _addSkillSellButton(px:Float, py:Float):MyButton2 {

    var cbFunc = function(btnID:Int) {
      if(btnID != SkillUI.BTN_ID_CANCEL) {
        // スキル売却
        var skill = SkillSlot.getSkill(btnID);
        // お金に換算
        var money = SkillUtil.getSell(skill.id);
        Global.addMoney(money);
        // スキル削除
        SkillSlot.delSkill(btnID);
        // 名前
        var name = SkillUtil.getName(skill.id);
        // メッセージ表示
        Message.push2(Msg.ITEM_SELL, [name, money]);
        Snd.playSe("coin", true);
      }

      // ボタン出現
      _appearBtn();
    }

    var label = UIMsg.get(UIMsg.SHOP_SKILL_SELL);
    var btn = new MyButton2(px, py, label, function() {
      // スキルUIを開く
      SkillUI.open(this, cbFunc, null, SkillUI.MODE_SELL);
      // メニュー非表示
      _group.visible = false;
    });

    return btn;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _fieldUI.update();
  }
}
