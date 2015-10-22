package jp_2dgames.game.gui;
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

  // ■スタティック
  static var _instance:SkillUI = null;
  static var _state:FlxState = null;

  // 開く
  public static function open(state:FlxState, cbFunc:Int->Void, actor:Actor, mode:Int):Void {
    _state = state;
    _instance = new SkillUI(cbFunc, actor, mode);
    state.add(_instance);
  }

  // ■メンバ変数

  // モード
  var _mode:Int;

  // ボタンリスト
  var _btnList:Array<MyButton>;

  // アイテム詳細UI
  var _detailUI:DetailUI;

  /**
   * コンストラクタ
   * @param cbFunc スキル選択コールバック
   * @param actor  行動主体者
   * @param mode   モード
   **/
  public function new(cbFunc:Int->Void, actor:Actor, mode:Int) {

    _mode = mode;

    // 基準座標を設定
    {
      var px = InventoryUI.BASE_X;
      var py = FlxG.height + InventoryUI.BASE_OFS_Y;
      super(px, py);
    }

    // ボタンの表示
    _displayButton(cbFunc, actor);

    // 詳細情報
    _detailUI = new DetailUI();
    _state.add(_detailUI);
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
  private function _displayButton(cbFunc:Int->Void, actor:Actor):Void {

    _btnList = new Array<MyButton>();

    var px = InventoryUI.BTN_X;
    var py = InventoryUI.BTN_Y;
    for(btnID in 0...SkillSlot.count()) {
      var skill = SkillSlot.getSkill(btnID);
      var label = SkillUtil.getName(skill.id);
      var btn = new MyButton(px, py, label, function() {
        // ボタンを押した
        cbFunc(btnID);
        // UIを閉じる
        _close();
      });

      // 要素番号を入れておく
      btn.ID = btnID;
      _btnList.push(btn);
      this.add(btn);

      // 売却価格の表示
      this.add(UIUtil.createPriceBG(px, py));
      var label = '${SkillUtil.getSell(skill.id)}G';
      var txt = UIUtil.createPriceText(px, py, label);
      this.add(txt);

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
      this.add(btn);
    }

    // 出現アニメーション
    {
      var py2 = FlxG.height + InventoryUI.BASE_OFS_Y;
      y = FlxG.height;
      FlxTween.tween(this, {y:py2}, 0.5, {ease:FlxEase.expoOut});
    }
  }

  /**
   * 閉じる
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

    _detailUI.visible = false;
  }
}
