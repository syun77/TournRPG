package jp_2dgames.game.state;

import flixel.text.FlxText;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.gui.Dialog;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.skill.SkillSlot;
import jp_2dgames.game.gui.SkillUI;
import jp_2dgames.game.gui.MyButton2;
import jp_2dgames.game.gui.UIUtil;
import jp_2dgames.game.gui.BtlCharaUI;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.gui.UIMsg;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.actor.Actor;

/**
 * フィールドのサブメニュー
 **/
class FieldSubState extends FlxSubState {

  static inline var STATUS_OFS_X = 64;
  static inline var STATUS_Y = 48;
  static inline var STATUS_DY = 12;

  // Actor情報
  var _actor:Actor;

  // メニューを閉じたときに実行する関数
  var _cbClose:Void->Void;

  // ■各種UI
  // メニュー管理
  var _group:FlxSpriteGroup;

  // アイテムボタン
  var _btnItem:MyButton2;
  // アイテムを捨てるボタン
  var _btnItemDel:MyButton2;
  // スキル確認ボタン
  var _btnSkill:MyButton2;

  // キャラUI
  var _ui:BtlCharaUI;

  // ステータス
  var _txtStr:FlxText;
  var _txtVit:FlxText;
  var _txtAgi:FlxText;
  var _txtMag:FlxText;

  // ステータステキストグループ
  var _groupTxt:FlxSpriteGroup;

  /**
   * コンストラクタ
   **/
  public function new(actor:Actor, ui:BtlCharaUI, cbClose:Void->Void) {
    super();
    _actor   = actor;
    _ui      = ui;
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

    // 背景
    {
      var bg = UIUtil.createMenuBG(0, UIUtil.MENU_BG_OFS_Y);
      _group.add(bg);
    }

    // 各ボタンを配置
    _displayButton();

    _appearBtn();

    _group.scrollFactor.set();

    // ステータスグループ
    _groupTxt = new FlxSpriteGroup(FlxG.width - STATUS_OFS_X, STATUS_Y);
    _addStatusText();
    _groupTxt.scrollFactor.set();
    this.add(_groupTxt);
    {
      // 出現演出
      var px2 = _groupTxt.x;
      _groupTxt.x = FlxG.width;
      FlxTween.tween(_groupTxt, {x:px2}, 0.5, {ease:FlxEase.expoOut});
    }
  }

  /**
   * ステータステキストの作成
   **/
  private function _createStatusText(px:Float, py:Float):FlxText {
    var txt = new FlxText(px, py);
    txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    txt.setBorderStyle(FlxText.BORDER_SHADOW);
    _groupTxt.add(txt);
    return txt;
  }

  /**
   * ステータステキストの作成
   **/
  private function _addStatusText():Void {
    var px = 0;
    var py = 0;
    _txtStr = _createStatusText(px, py); py += STATUS_DY;
    _txtVit = _createStatusText(px, py); py += STATUS_DY;
    _txtAgi = _createStatusText(px, py); py += STATUS_DY;
    _txtMag = _createStatusText(px, py); py += STATUS_DY;

    _updateStatusText();
  }

  /**
   * ステータステキストの更新
   **/
  private function _updateStatusText():Void {
    _txtStr.text = '${UIMsg.get(UIMsg.STATUS_STR)}: ${_actor.str}';
    _txtVit.text = '${UIMsg.get(UIMsg.STATUS_VIT)}: ${_actor.vit}';
    _txtAgi.text = '${UIMsg.get(UIMsg.STATUS_AGI)}: ${_actor.agi}';
    _txtMag.text = '${UIMsg.get(UIMsg.STATUS_MAG)}: ${_actor.mag}';
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

    px += InventoryUI.BTN_DX;
    // アイテムを捨てるボタン
    {
      _btnItemDel = _addItemDelButton(px, py);
      _group.add(_btnItemDel);
    }

    px += InventoryUI.BTN_DX;
    // スキル確認ボタン
    {
      _btnSkill = _addSkillButton(px, py);
      _group.add(_btnSkill);
    }

    px += InventoryUI.BTN_DX;
    py += InventoryUI.BTN_DY;
    {
      // 他にボタンを追加する場合はここに追加
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
   * アイテムを使うコールバック関数
   **/
  private function _cbItemUse(result:InventoryUIResult):Void {
    var uid = result.uid;
    if(uid != InventoryUI.CMD_CANCEL) {

      // アイテムを使う
      var item = Inventory.getItem(uid);
      ItemUtil.use(_actor, item, true);
      Inventory.delItem(uid);

      // ステータス更新
      _updateStatusText();

      if(Inventory.isEmpty() == false) {
        // 再び開く
        var param = new InventoryUIParam(InventoryUI.MODE_NORMAL, false, result.nPage);
        InventoryUI.open(this, _cbItemUse, _actor, param);
        return;
      }
    }

    // ボタンを再表示
    _appearBtn();
  }

  /**
   * アイテムボタンを配置
   **/
  private function _addItemButton(px:Float, py:Float):MyButton2 {

    var label = UIMsg.get(UIMsg.CMD_ITEM);
    var btn = new MyButton2(px, py, label, function() {
      // インベントリを開く
      var param = new InventoryUIParam(InventoryUI.MODE_NORMAL);
      InventoryUI.open(this, _cbItemUse, _actor, param);
      // メニュー非表示
      _group.visible = false;
    });

    return btn;
  }

  /**
   * スキル確認
   **/
  private function _cbSkillView(btnID:Int):Void {

    if(btnID == SkillUI.BTN_ID_CANCEL) {
      // ボタンを再表示
      _appearBtn();
      return;
    }

    var skill = SkillSlot.getSkill(btnID);
    var name = SkillUtil.getName(skill.id);
    var msg = UIMsg.get2(UIMsg.DEL_CONFIRM, [name]);
    Dialog.open(this, Dialog.YESNO, msg, null, function(nSel) {
      if(nSel == Dialog.BTN_YES) {
        // 捨てる
        SkillSlot.delSkill(btnID, _actor);
        Message.push2(Msg.ITEM_DEL, [name]);
        Snd.playSe("del");
      }

      if(SkillSlot.isEmpty() == false) {
        // スキルUIを開く
        SkillUI.open(this, _cbSkillView, _actor, SkillUI.MODE_VIEW, false);
      }
      else {
        // ボタンを再表示
        _appearBtn();
      }
    });
  }

  /**
   * スキルボタンを配置
   **/
  private function _addSkillButton(px:Float, py:Float):MyButton2 {

    var label = UIMsg.get(UIMsg.SKILL_VIEW);
    var btn = new MyButton2(px, py, label, function() {
      // スキルUIを開く
      SkillUI.open(this, _cbSkillView, _actor, SkillUI.MODE_VIEW, true);
      // メニュー非表示
      _group.visible = false;
    });

    return btn;
  }

  /**
   * アイテム削除
   **/
  private function _cbItemDel(result:InventoryUIResult):Void {
    var uid = result.uid;
    if(uid != InventoryUI.CMD_CANCEL) {
      // アイテムを捨てる
      var item = Inventory.getItem(uid);
      var name = ItemUtil.getName(item);
      // アイテム削除
      Inventory.delItem(uid);
      Message.push2(Msg.ITEM_DEL, [name]);
      Snd.playSe("del");

      if(Inventory.isEmpty() == false) {
        // 再び表示
        var param = new InventoryUIParam(InventoryUI.MODE_DROP, false, result.nPage);
        InventoryUI.open(this, _cbItemDel, null, param);
        return;
      }
    }
    // ボタンを再表示
    _appearBtn();
  }

  /**
   * アイテムを捨てるボタンを配置
   **/
  private function _addItemDelButton(px:Float, py:Float):MyButton2 {

    var label = UIMsg.get(UIMsg.ITEM_DROP);
    var btn = new MyButton2(px, py, label, function() {
      // インベントリUIを開く
      var param = new InventoryUIParam(InventoryUI.MODE_DROP);
      InventoryUI.open(this, _cbItemDel, null, param);
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

    // UI更新
    _ui.update();

    // アイテムボタンを押せるかどうかチェック
    _btnItem.enabled = (Inventory.isEmpty() == false);
    // アイテム捨てるボタンを押せるかどうかチェック
    _btnItemDel.enabled = (Inventory.isEmpty() == false);
    // スキル確認ボタンを押せるかどうかチェック
    _btnSkill.enabled = (SkillSlot.isEmpty() == false);

    // メッセージ更新
    Message.forceUpdate();
  }
}
