package jp_2dgames.game.gui;
import jp_2dgames.game.gui.UIMsg;
import flixel.ui.FlxButton;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.actor.Actor;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * ショップ回復メニュー
 **/
class ShopRecoveryUI extends FlxSpriteGroup {

  // ■定数
  public static inline var BTN_ID_CANCEL:Int       = -1; // キャンセル
  public static inline var BTN_ID_RECOVER:Int      = 0; // 少しだけ回復する
  public static inline var BTN_ID_RECOVER_FULL:Int = 1; // 全回復

  // ■スタティック
  static var _instance:ShopRecoveryUI = null;
  static var _state:FlxState = null;

  // 開く
  public static function open(state:FlxState, cbFunc:Int->Int->Void, actor:Actor, bAnim:Bool):Void {
    _state = state;
    _instance = new ShopRecoveryUI(cbFunc, actor, bAnim);
    state.add(_instance);
  }

  // ■メンバ変数

  // ボタンリスト
  var _btnList:Array<MyButton2> = null;

  // 詳細説明
  var _detailUI:DetailUI;

  /**
   * コンストラクタ
   **/
  public function new(cbFunc:Int->Int->Void, actor:Actor, bAnim:Bool) {

    // 基準座標を設定
    {
      var px = InventoryUI.BASE_X;
      var py = FlxG.height + InventoryUI.BASE_OFS_Y;
      super(px, py);
    }

    // 背景
    {
      var bg = UIUtil.createMenuBG(0, UIUtil.MENU_BG_OFS_Y);
      this.add(bg);
    }

    // ボタンの表示
    _displayButton(cbFunc, actor, bAnim);

    // 詳細情報
    _detailUI = new DetailUI();
    _state.add(_detailUI);

    scrollFactor.set();
  }

  /**
   * 消滅
   **/
  override public function destroy():Void {
    _detailUI = FlxDestroyUtil.destroy(_detailUI);
    super.destroy();
  }

  /**
   * ボタン表示
   **/
  private function _displayButton(cbFunc:Int->Int->Void, actor:Actor, bAnim:Bool):Void {
    _btnList = new Array<MyButton2>();

    var px = InventoryUI.BTN_X;
    var py = InventoryUI.BTN_Y;

    // 回復ボタン
    var btnIDs = [BTN_ID_RECOVER, BTN_ID_RECOVER_FULL];
    for(btnID in btnIDs) {
      // ラベルID
      var msgID = _getLabel(btnID);
      // コスト
      var cost  = _getCost(btnID, actor);
      // ラベル
      var label = UIMsg.get(msgID);
      // ボタン生成
      var btn = new MyButton2(px, py, label, function() {
        // UIを閉じる
        _close();
        // ボタンを押した
        cbFunc(btnID, cost);
      });

      // 要素番号を入れておく
      btn.ID = btnID;
      // ボタンをクリックできるかどうか
      btn.enabled = _checkEnabled(btnID, actor);
      _btnList.push(btn);
      this.add(btn);

      // コスト表示
      this.add(UIUtil.createPriceBG(px, py));
      var label = '${cost}G';
      var txt = UIUtil.createPriceText(px, py, label);
      this.add(txt);

      px += InventoryUI.BTN_DX;
    }

    // キャンセルボタン
    {
      var px = InventoryUI.BTN_CANCEL_X;
      var py = InventoryUI.BTN_CANCEL_Y;
      var label = UIMsg.get(UIMsg.CANCEL);
      var btn = new MyButton2(px, py, label, function() {
        cbFunc(BTN_ID_CANCEL, 0);
        // UIを閉じる
        _close();
      });
      btn.ID = BTN_ID_CANCEL;
      btn.color       = MyColor.BTN_CANCEL;
      btn.label.color = MyColor.BTN_CANCEL_LABEL;
      this.add(btn);
    }

    // 出現アニメーション
    if(bAnim) {
      var py2 = FlxG.height + InventoryUI.BASE_OFS_Y;
      y = FlxG.height;
      FlxTween.tween(this, {y:py2}, 0.5, {ease:FlxEase.expoOut});
    }
  }

  /**
   * 閉じる
   **/
  private function _close():Void {
    _state.remove(_detailUI);
    destroy();
    _state = null;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _detailUI.visible = false;
    for(btn in _btnList) {
      switch(btn.status) {
        case FlxButton.HIGHLIGHT, FlxButton.PRESSED:
          var idx = btn.ID;
          if(idx < 0) {
            continue;
          }

          _detailUI.visible = true;
          // 表示情報を更新
          var msg = UIMsg.get(_getDetail(btn.ID));
          _detailUI.setText(msg);
          break;
      }
    }
  }

  /**
   * ボタンのラベル番号取得
   **/
  private function _getLabel(btnID:Int):Int {
    switch(btnID) {
      case BTN_ID_RECOVER: return UIMsg.SHOP_REC_LITTLE;
      case BTN_ID_RECOVER_FULL: return UIMsg.SHOP_REC_FULL;
      default: return 0;
    }
  }

  /**
   * コストを取得
   **/
  private function _getCost(btnID:Int, actor:Actor):Int {

    var base:Int = 50;
    var lv:Int   = actor.lv;
    var cost = (base + lv*4) * (1 + lv * 0.2);
    var cost10   = cost * 0.1;
    var costFull = cost * (1 - actor.hpratio);

    switch(btnID) {
      case BTN_ID_RECOVER: return Std.int(cost10);
      case BTN_ID_RECOVER_FULL: return Std.int(costFull);
      default: return 0;
    }
  }

  /**
   * ボタンをクリックできるかどうか
   **/
  private function _checkEnabled(btnID:Int, actor:Actor):Bool {
    switch(btnID) {
      case BTN_ID_RECOVER: return actor.hpratio <= 0.9;
      case BTN_ID_RECOVER_FULL: return true;
      default: return true;
    }
  }


  /**
   * 詳細メッセージ
   **/
  private function _getDetail(btnID:Int):Int {
    switch(btnID) {
      case BTN_ID_RECOVER: return UIMsg.MSG_REC_LITTLE;
      case BTN_ID_RECOVER_FULL: return UIMsg.MSg_REC_FULL;
      default: return 0;
    }
  }
}
