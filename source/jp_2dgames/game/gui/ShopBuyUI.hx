package jp_2dgames.game.gui;

import jp_2dgames.game.gui.message.UIMsg;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.skill.SkillSlot;
import flixel.util.FlxDestroyUtil;
import flixel.FlxSprite;
import flixel.text.FlxText;
import jp_2dgames.game.skill.SkillUtil;
import flixel.ui.FlxButton;
import jp_2dgames.game.item.ItemUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.FlxG;
import jp_2dgames.game.actor.Actor;
import flixel.group.FlxSpriteGroup;

/**
 * ショップ購入メニュー
 **/
class ShopBuyUI extends FlxSpriteGroup {

  // ■定数
  public static inline var BTN_ID_CANCEL:Int = -1;

  // カテゴリ
  public static inline var CATEGORY_ITEM:Int  = 0; // 消耗品
  public static inline var CATEGORY_EQUIP:Int = 1; // 装備品
  public static inline var CATEGORY_SKILL:Int = 2; // スキル
  public static inline var CATEGORY_FOOD:Int  = 3; // 食糧

  // カテゴリの座標
  static inline var CATEGORY_X = InventoryUI.BTN_X + 16;
  static inline var CATEGORY_Y = InventoryUI.BTN_Y - 40;
  static inline var CATEGORY_DX = 48;

  // ボタンの最大数
  static inline var BUTTON_MAX:Int = 8;

  // ■スタティック
  static var _instance:ShopBuyUI = null;
  static var _state:FlxState = null;

  // 開く
  public static function open(state:FlxState, cbFunc:Int->Int->Void, actor:Actor, category:Int, bAnim:Bool):Void {
    _state = state;
    _instance = new ShopBuyUI(cbFunc, actor, category, bAnim);
    state.add(_instance);
  }

  // ■メンバ変数

  // ボタンリスト
  var _btnList:Array<MyButton2>;

  // カテゴリカーソル
  var _cursor:FlxSprite;

  // カテゴリ
  var _category:Int;

  // 装備品UI
  var _equipUI:EquipUI;

  // アイテム詳細UI
  var _detailUI:DetailUI;

  // 表示アニメーション
  var _tween:FlxTween = null;

  /**
   * コンストラクタ
   * @param cbFunc   アイテム選択コールバック
   * @param actor    行動主体者
   * @param category カテゴリ
   * @param bAnim    出現アニメーションの有無
   **/
  public function new(cbFunc:Int->Int->Void, actor:Actor, category:Int, bAnim:Bool) {

    // 基準座標を設定
    {
      var px = InventoryUI.BASE_X;
      var py = FlxG.height + InventoryUI.BASE_OFS_Y;
      super(px, py);
    }

    // カテゴリ
    _category = category;

    // ボタンの表示
    _displayButton(cbFunc, actor, bAnim);

    // 装備情報
    _equipUI = new EquipUI();
    _state.add(_equipUI);

    // アイテム詳細
    _detailUI = new DetailUI();
    _state.add(_detailUI);

    scrollFactor.set();
  }

  /**
   * 消滅
   **/
  override public function destroy():Void {
    super.destroy();

    _state.remove(_detailUI);
    _state.remove(_equipUI);
    _detailUI = FlxDestroyUtil.destroy(_detailUI);
    _equipUI = FlxDestroyUtil.destroy(_equipUI);
  }

  /**
   * アイテムが空かどうか
   **/
  private function isItemEmpty(category:Int):Bool {
    return _getItemLength(category) <= 0;
  }

  /**
   * アイテムの数を取得する
   **/
  private function _getItemLength(category:Int=-1):Int {
    var shop = Global.getShopData();

    if(category == -1) {
      category = _category;
    }

    switch(category) {
      case CATEGORY_ITEM:
        return shop.itemList.length;
      case CATEGORY_EQUIP:
        return shop.equipList.length;
      case CATEGORY_SKILL:
        return shop.skillList.length;
      case CATEGORY_FOOD:
        return shop.food;
    }

    return 0;
  }

  /**
   * アイテムの名前を取得する
   **/
  private function _getItemName(idx:Int):String {
    var shop = Global.getShopData();

    switch(_category) {
      case CATEGORY_ITEM:
        return ItemUtil.getName(shop.itemList[idx]);
      case CATEGORY_EQUIP:
        return ItemUtil.getName(shop.equipList[idx]);
      case CATEGORY_SKILL:
        return SkillUtil.getName(shop.skillList[idx].id);
      case CATEGORY_FOOD:
        return UIMsg.get(UIMsg.FOOD);
    }

    return "";
  }

  /**
   * アイテムの詳細を取得する
   **/
  private function _getItemDetail(idx:Int):String {
    var shop = Global.getShopData();

    switch(_category) {
      case CATEGORY_ITEM:
        return ItemUtil.getDetail(shop.itemList[idx]);
      case CATEGORY_EQUIP:
        return ItemUtil.getDetail(shop.equipList[idx]);
      case CATEGORY_SKILL:
        return SkillUtil.getDetail2(shop.skillList[idx].id, null);
      case CATEGORY_FOOD:
        return UIMsg.get(UIMsg.MSG_FOOD);
    }

    return "";
  }

  /**
   * アイテムの購入価格を取得する
   **/
  private function _getItemBuy(idx:Int):Int {
    var shop = Global.getShopData();

    switch(_category) {
      case CATEGORY_ITEM:
        return ItemUtil.getBuy(shop.itemList[idx]);
      case CATEGORY_EQUIP:
        return ItemUtil.getBuy(shop.equipList[idx]);
      case CATEGORY_SKILL:
        return SkillUtil.getBuy(shop.skillList[idx].id);
      case CATEGORY_FOOD:
        return Reg.COST_FOOD;
    }

    return 0;
  }

  /**
   * ボタンの表示
   **/
  private function _displayButton(cbFunc:Int->Int->Void, actor:Actor, bAnim:Bool):Void {

    // 背景
    {
      var bg = UIUtil.createMenuBG(0, UIUtil.MENU_BG_OFS_Y);
      this.add(bg);
    }

    // コマンドボタンの配置
    _btnList = new Array<MyButton2>();

    var length = _getItemLength();
    for(btnID in 0...length) {
      var px = InventoryUI.BTN_X + InventoryUI.BTN_DX * (btnID%3);
      var py = InventoryUI.BTN_Y + InventoryUI.BTN_DY * Math.floor(btnID/3);

      var label = _getItemName(btnID);
      var btn = new MyButton2(px, py, label, function() {

        // UIを閉じる
        _close();
        // ボタンを押した
        cbFunc(btnID, _category);
      });
      // 要素番号を入れておく
      btn.ID = btnID;
      _btnList.push(btn);
      this.add(btn);

      // 購入価格の表示
      this.add(UIUtil.createPriceBG(px, py));
      var money = _getItemBuy(btnID);
      var txt = UIUtil.createPriceText(px, py, '${money}G');
      this.add(txt);

      if(Global.getMoney() < money) {
        // 所持金が足りない
        btn.enabled = false;
      }
      if(_category == CATEGORY_SKILL) {
        if(SkillSlot.isLimit()) {
          // スキルが最大に達しているので、スキルは買えない
          btn.enabled = false;
        }
      }
    }

    // キャンセルボタン
    {
      var px = InventoryUI.BTN_CANCEL_X;
      var py = InventoryUI.BTN_CANCEL_Y;
      var label = UIMsg.get(UIMsg.CANCEL);
      var btn = new MyButton2(px, py, label, function() {
        cbFunc(BTN_ID_CANCEL, _category);
        // UIを閉じる
        _close();
      });
      btn.ID = BTN_ID_CANCEL;
      btn.color       = MyColor.BTN_CANCEL;
      btn.label.color = MyColor.BTN_CANCEL_LABEL;
      this.add(btn);
    }

    // カテゴリボタン
    _addCategoryButton(cbFunc, actor);

    // カテゴリカーソル
    _addCategoryCursor();

    if(bAnim) {

      // 出現アニメーション
      if(_tween != null) {
        // いったんキャンセル
        _tween.cancel();
      }
      var py2 = FlxG.height + InventoryUI.BASE_OFS_Y;
      y = FlxG.height;
      _tween = FlxTween.tween(this, {y:py2}, 0.5, {ease:FlxEase.expoOut});
    }
  }

  /**
   * カテゴリボタンの追加
   **/
  private function _addCategoryButton(cbFunc:Int->Int->Void, actor:Actor):Void {
    var px = CATEGORY_X;
    var py = CATEGORY_Y;

    // カテゴリ種別
    var tbl = [
      CATEGORY_ITEM,  // 消耗品
      CATEGORY_EQUIP, // 装備品
      CATEGORY_SKILL, // スキル
      CATEGORY_FOOD   // 食糧
    ];

    // アイコン画像
    var fnImage = function(type:Int) {
      switch(type) {
        case CATEGORY_ITEM: return Reg.PATH_SHOP_ITEM;
        case CATEGORY_EQUIP: return Reg.PATH_SHOP_EQUIP;
        case CATEGORY_SKILL: return Reg.PATH_SHOP_SKILL;
        default: return Reg.PATH_SHOP_FOOD;
      }
    };

    // アイコンをクリックできるかどうか
    var fnEmpty = function(type:Int) {
      var shop = Global.getShopData();
      switch(type) {
        case CATEGORY_ITEM: return shop.isEmptyItem();
        case CATEGORY_EQUIP: return shop.isEmptyEquip();
        case CATEGORY_SKILL: return shop.isEmptySkill();
        default: return shop.isEmptyFood();
      }
    }

    // ボタン生成
    for(type in tbl) {
      // カテゴリボタンを押した
      var func = function() {
        // いったん全部消す
        for(obj in members) {
          this.remove(obj);
          obj = FlxDestroyUtil.destroy(obj);
        }
        _category = type;
        if(type == CATEGORY_SKILL) {
          if(SkillSlot.isLimit()) {
            // スキルが買えないので警告メッセージ表示
            Message.push2(Msg.SKILL_CANT_BUY);
          }
        }
        _displayButton(cbFunc, actor, false);
      }
      var btn = new MyButton(px, py, "", func);
      btn.loadGraphic(fnImage(type), true);
      btn.enabled = fnEmpty(type) == false;
      this.add(btn);
      px += CATEGORY_DX;
    }
  }

  /**
   * カテゴリカーソルの追加
   **/
  private function _addCategoryCursor():Void {
    var px = CATEGORY_X + (CATEGORY_DX * _category);
    var py = CATEGORY_Y;
    var cursor = new FlxSprite(px, py);
    cursor.loadGraphic(Reg.PATH_SHOP_CURSOR);
    this.add(cursor);
  }

  /**
   * UIを閉じる
   **/
  private function _close():Void {
    _state.remove(this);
    _instance = FlxDestroyUtil.destroy(_instance);
    _state = null;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // いったん非表示
    _detailUI.visible = false;
    // ボタンの種類を調べる
    for(btn in _btnList) {
      switch(btn.status) {
        case FlxButton.HIGHLIGHT, FlxButton.PRESSED:
          _detailUI.visible = true;
          var idx = btn.ID;
          if(idx < 0) {
            continue;
          }

          // 表示情報を更新
          var detail = _getItemDetail(idx);
          _detailUI.setText(detail);
          break;
      }
    }
  }
}
