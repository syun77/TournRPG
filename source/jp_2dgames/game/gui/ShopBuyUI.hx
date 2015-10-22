package jp_2dgames.game.gui;

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
  public static function open(state:FlxState, cbFunc:Int->Int->Void, actor:Actor):Void {
    _state = state;
    _instance = new ShopBuyUI(cbFunc, actor);
    state.add(_instance);
  }

  // ■メンバ変数

  // ボタンリスト
  var _btnList:Array<MyButton>;

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
   * @param cbFunc アイテム選択コールバック
   * @param actor  行動主体者
   **/
  public function new(cbFunc:Int->Int->Void, actor:Actor) {

    // 基準座標を設定
    {
      var px = InventoryUI.BASE_X;
      var py = FlxG.height + InventoryUI.BASE_OFS_Y;
      super(px, py);
    }

    // カテゴリ
    _category = CATEGORY_ITEM;

    // ボタンの表示
    _displayButton(cbFunc, actor);

    // 装備情報
    _equipUI = new EquipUI();
    _state.add(_equipUI);

    // アイテム詳細
    _detailUI = new DetailUI();
    _state.add(_detailUI);

    for(obj in members) {
      obj.scrollFactor.set(0, 0);
    }
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    _state.remove(_detailUI);
    _state.remove(_equipUI);

    super.kill();
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
        return SkillUtil.getDetail2(shop.skillList[idx].id);
    }

    return "";
  }

  /**
   * ボタンの表示
   **/
  private function _displayButton(cbFunc:Int->Int->Void, actor:Actor):Void {

    // コマンドボタンの配置
    _btnList = new Array<MyButton>();

    var px = InventoryUI.BTN_X;
    var py = InventoryUI.BTN_Y;

    var length = _getItemLength();
    for(btnID in 0...length) {
      var label = _getItemName(btnID);
      var btn = new MyButton(px, py, label, function() {

        // ボタンを押した
        cbFunc(btnID, _category);
        // UIを閉じる
        _close();
      });
      // 要素番号を入れておく
      btn.ID = btnID;
      _btnList.push(btn);

      px += InventoryUI.BTN_DX;
    }

    // キャンセルボタン
    {
      var px = InventoryUI.BTN_CANCEL_X;
      var py = InventoryUI.BTN_CANCEL_Y;
      var label = UIMsg.get(UIMsg.CANCEL);
      var btn = new MyButton(px, py, label, function() {
        cbFunc(BTN_ID_CANCEL, _category);
        // UIを閉じる
        _close();
      });
      btn.ID = BTN_ID_CANCEL;
      btn.color       = MyColor.BTN_CANCEL;
      btn.label.color = MyColor.BTN_CANCEL_LABEL;
      _btnList.push(btn);
    }

    for(btn in _btnList) {
      this.add(btn);
      btn.scrollFactor.set(0, 0);
    }

    // カテゴリボタン
    _addCategoryButton(cbFunc, actor);

    // 出現アニメーション
    if(_tween != null) {
      _tween.cancel();
    }
    {
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
      CATEGORY_SKILL  // スキル
    ];

    // アイコン画像
    var fnImage = function(type:Int) {
      switch(type) {
        case CATEGORY_ITEM: return Reg.PATH_SHOP_ITEM;
        case CATEGORY_EQUIP: return Reg.PATH_SHOP_EQUIP;
        default: return Reg.PATH_SHOP_SKILL;
      }
    };

    // ボタン生成
    for(type in tbl) {
      var func = function() {
        // いったん全部消す
        for(obj in members) {
          this.remove(obj);
        }
        _category = type;
        _displayButton(cbFunc, actor);
      }
      var btn = new FlxButton(px, py, "", func);
      btn.loadGraphic(fnImage(type), true);
      this.add(btn);
      px += CATEGORY_DX;
    }
  }

  /**
   * UIを閉じる
   **/
  private function _close():Void {
    kill();
    _state.remove(this);
    _instance = null;
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
