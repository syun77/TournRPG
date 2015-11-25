package jp_2dgames.game.gui;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.gui.InventoryUI;
import flixel.util.FlxDestroyUtil;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxSprite;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.skill.SkillSlot;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import jp_2dgames.game.actor.Actor;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * スキル選択UI
 **/
class SkillUI extends FlxSpriteGroup {

  // ■定数
  public static inline var BTN_ID_CANCEL:Int = -1;

  // モード
  public static inline var MODE_SELL:Int = 0; // 売却モード
  public static inline var MODE_VIEW:Int = 1; // 確認モード

  // ■スタティック
  static var _instance:SkillUI = null;
  static var _state:FlxState = null;

  // 開く
  public static function open(state:FlxState, cbFunc:Int->Void, actor:Actor, mode:Int, bAnim:Bool):Void {
    _state = state;
    _instance = new SkillUI(cbFunc, actor, mode, bAnim);
    state.add(_instance);
  }

  // ■メンバ変数

  // モード
  var _mode:Int;

  // ボタンリスト
  var _btnList:Array<MyButton2> = null;

  // アイテム詳細UI
  var _detailUI:DetailUI;

  var _actor:Actor;

  /**
   * コンストラクタ
   * @param cbFunc スキル選択コールバック
   * @param actor  行動主体者
   * @param mode   モード
   * @param bAnim  表示アニメの有無
   **/
  public function new(cbFunc:Int->Void, actor:Actor, mode:Int, bAnim:Bool) {

    _mode = mode;
    _actor = actor;

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
  override public function kill():Void {
    _state.remove(_detailUI);
    super.kill();
  }

  /**
   * ボタン表示
   **/
  private function _displayButton(cbFunc:Int->Void, actor:Actor, bAnim:Bool):Void {

    _btnList = new Array<MyButton2>();

    for(btnID in 0...SkillSlot.count()) {
      var px = InventoryUI.BTN_X + InventoryUI.BTN_DX * (btnID%3);
      var py = InventoryUI.BTN_Y + InventoryUI.BTN_DY * Math.floor(btnID/3);

      var skill = SkillSlot.getSkill(btnID);
      var label = SkillUtil.getName(skill.id);
      var btn = new MyButton2(px, py, label, function() {
        // UIを閉じる
        _close();
        // ボタンを押した
        cbFunc(btnID);
      });

      // 要素番号を入れておく
      btn.ID = btnID;
      _btnList.push(btn);
      this.add(btn);

      if(_mode == MODE_SELL) {
        // 売却価格の表示
        this.add(UIUtil.createPriceBG(px, py));
        var label = '${SkillUtil.getSell(skill.id)}G';
        var txt = UIUtil.createPriceText(px, py, label);
        this.add(txt);
      }
    }

    // キャンセルボタン
    {
      var px = InventoryUI.BTN_CANCEL_X;
      var py = InventoryUI.BTN_CANCEL_Y;
      var label = UIMsg.get(UIMsg.CANCEL);
      var btn = new MyButton2(px, py, label, function() {
        cbFunc(BTN_ID_CANCEL);
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
    _state.remove(this);
    _detailUI = FlxDestroyUtil.destroy(_detailUI);
    _instance = FlxDestroyUtil.destroy(_instance);
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
          var skill = SkillSlot.getSkill(idx);
          var detail = SkillUtil.getDetail2(skill.id, _actor);
          _detailUI.setText(detail);
          break;
      }
    }
  }
}
