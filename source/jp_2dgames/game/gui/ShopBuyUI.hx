package jp_2dgames.game.gui;

import jp_2dgames.game.item.Inventory;
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
   * UIを閉じる
   **/
  private function _close():Void {
    kill();
    _state.remove(this);
    _instance = null;
    _state = null;
  }
}
