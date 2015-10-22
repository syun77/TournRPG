package jp_2dgames.game.gui;

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
  public static function open(state:FlxState, cbFunc:Int->Void, actor:Actor):Void {
    _state = state;
    _instance = new ShopBuyUI(cbFunc, actor);
    state.add(_instance);
  }

  // ■メンバ変数

  // ボタンリスト
  var _btnList:Array<MyButton>;

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
  public function new(cbFunc:Int->Void, actor:Actor) {

    // 基準座標を設定
    {
      var px = InventoryUI.BASE_X;
      var py = FlxG.height + InventoryUI.BASE_OFS_Y;
      super(px, py);
    }

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
   * ボタンの表示
   **/
  private function _displayButton(cbFunc:Int->Void, actor:Actor):Void {

    // コマンドボタンの配置
    _btnList = new Array<MyButton>();

    var px = InventoryUI.BTN_X;
    var py = InventoryUI.BTN_Y;
    var itemList = Global.getShopData().itemList;
    for(btnID in 0...itemList.length) {
      var item = itemList[btnID];
      var label = ItemUtil.getName(item);
      var btn = new MyButton(px, py, label, function() {

        // ボタンを押した
        cbFunc(btnID);
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
        cbFunc(BTN_ID_CANCEL);
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
    _addCategoryButton();

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
  private function _addCategoryButton():Void {
    var px = CATEGORY_X;
    var py = CATEGORY_Y;
    // 消耗品
    {
      var btn = new FlxButton(px, py, "", null);
      btn.loadGraphic(Reg.PATH_SHOP_ITEM, true);
      this.add(btn);
    }
    px += CATEGORY_DX;

    // 装備品
    {
      var btn = new FlxButton(px, py, "", null);
      btn.loadGraphic(Reg.PATH_SHOP_EQUIP, true);
      this.add(btn);
    }
    px += CATEGORY_DX;

    // スキル
    {
      var btn = new FlxButton(px, py, "", null);
      btn.loadGraphic(Reg.PATH_SHOP_SKILL, true);
      this.add(btn);
    }
    px += CATEGORY_DX;
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
          var item = Global.getShopData().itemList[btn.ID];
          var detail = ItemUtil.getDetail(item);
          _detailUI.setText(detail);
          break;
      }
    }
  }
}
