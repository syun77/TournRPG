package jp_2dgames.game.gui;
import jp_2dgames.game.skill.SkillConst;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.btl.BtlGroupUtil;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.btl.types.BtlCmd;
import jp_2dgames.game.actor.Actor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * バトルコマンドUI
 **/
class BtlCmdUI extends FlxSpriteGroup {

  // ■定数
  // 座標
  private static inline var BASE_X = 0;
  private static inline var BASE_OFS_Y = -(BTN_DY*3.5);

  // ボタン
  private static inline var BTN_X = Reg.BTN_OFS_X;
  private static inline var BTN_Y = 0;
  private static inline var BTN_DX = MyButton.WIDTH + Reg.BTN_OFS_DX;
  private static inline var BTN_DY = MyButton.HEIGHT + Reg.BTN_OFS_DY;

  // ■メンバ変数

  // アイテム選択用のコールバック関数
  private var _cbItem:Int->Void = null;

  /**
   * コンストラクタ
   * @param actor 行動主体者
   * @param cbFunc コマンド実行コールバック関数
   **/
  public function new(actor:Actor, cbFunc:Actor->BtlCmd->Void) {

    // アイテム選択のコール関数を登録しておく
    _cbItem = function(btnID:Int) {

      // アイテム取得
      var item = Inventory.getItem(btnID);
      // インベントリから削除
      Inventory.delItem(btnID);

      // ここでは使うアイテムのみ登録
      cbFunc(actor, BtlCmd.Item(item, null, 0));
    };

    // 基準座標を設定
    {
      var px = BASE_X;
      super(px, 0);
    }

    // コマンドボタンの配置
    var btnList = new List<MyButton>();
    var px = BTN_X;
    var py = BTN_Y;
    var lblAtk = UIMsg.get(UIMsg.CMD_ATK);
    btnList.add(new MyButton(px, py, lblAtk, function() {
      _attack(actor, cbFunc);
    }));
    px += BTN_DX;
    // TODO: スキルボタンにする
    var name = SkillUtil.getName(SkillConst.SKILL001);
    btnList.add(new MyButton(px, py, name, function() {
      // スキル1を選択
      _skill(actor, cbFunc, SkillConst.SKILL001);
    }));
    px += BTN_DX;
    // TODO: スキルボタンにする
    btnList.add(new MyButton(px, py, "SKILL2", function() {
      // スキル2を選択
      _skill(actor, cbFunc, SkillConst.SKILL003);
    }));

    // 2列目
    px = BTN_X;
    py += BTN_DY;
    var lblItem = UIMsg.get(UIMsg.CMD_ITEM);
    var btnItem = new MyButton(px, py, lblItem, function() {
      // インベントリ表示
      _displayInventoryUI(actor);
    });
    if(Inventory.isEmpty()) {
      // アイテムがないので選べない
      btnItem.enable = false;
    }
    btnList.add(btnItem);

    px += BTN_DX;
    var lblEscape = UIMsg.get(UIMsg.CMD_ESCAPE);
    btnList.add(new MyButton(px, py, lblEscape, function() {
      cbFunc(actor, BtlCmd.Escape(true));
    }));

    for(btn in btnList) {
      this.add(btn);
      btn.scrollFactor.set(0, 0);
    }

    // 表示
    _display();
  }

  private function _cbTarget(actor:Actor, cbFunc:Actor->BtlCmd->Void):Void {

  }

  /**
   * 攻撃コマンドを選んだ
   **/
  private function _attack(actor:Actor, cbFunc:Actor->BtlCmd->Void):Void {
    var group = BtlGroupUtil.getAgaint(actor.group);
    var range = BtlRange.One;

    BtlTargetUI.open(function(targetID) {
      if(targetID == BtlTargetUI.CMD_CANCEL) {
        // キャンセルした
        _display();
        visible = true;
        return;
      }
      // 攻撃
      cbFunc(actor, BtlCmd.Attack(range, targetID));
    }, group, range);

    visible = false;
  }

  /**
   * スキルコマンドを選んだ
   **/
  private function _skill(actor:Actor, cbFunc:Actor->BtlCmd->Void, btnID:Int):Void {
    // TODO: 相手グループをランダム攻撃
    var group = BtlGroupUtil.getAgaint(actor.group);
    var target = ActorMgr.random(group);

    cbFunc(actor, BtlCmd.Skill(btnID, BtlRange.One, target.ID));
  }

  /**
   * 表示開始
   **/
  private function _display():Void {
    visible = true;
    var py = FlxG.height + BASE_OFS_Y;
    y = FlxG.height;
    FlxTween.tween(this, {y:py}, 0.5, {ease:FlxEase.expoOut});
  }

  /**
   * インベントリUIを表示する
   **/
  private function _displayInventoryUI(actor:Actor):Void {
    InventoryUI.open(_cbItemSelect, actor);
    // 自身は非表示
    visible = false;
  }

  /**
   * アイテム選択のコールバック関数
   **/
  private function _cbItemSelect(btnID:Int):Void {

    if(btnID == InventoryUI.CMD_CANCEL) {
      // キャンセルしたのでコマンドUIを再び表示
      _display();
      return;
    }

    // アイテムを選んだ
    _cbItem(btnID);
  }
}
