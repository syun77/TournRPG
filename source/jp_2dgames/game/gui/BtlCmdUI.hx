package jp_2dgames.game.gui;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.skill.SkillSlot;
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
    // 攻撃
    var btnList = new List<MyButton>();
    var lblAtk = UIMsg.get(UIMsg.CMD_ATK);
    btnList.add(new MyButton(0, 0, lblAtk, function() {
      _attack(actor, cbFunc);
    }));

    //  スキル
    for(idx in 0...SkillSlot.count()) {
      var skill = SkillSlot.getSkill(idx);
      var name = SkillUtil.getName(skill.id);
      btnList.add(new MyButton(0, 0, name, function() {
        _skill(actor, cbFunc, skill);
      }));
    }

    // アイテム
    var lblItem = UIMsg.get(UIMsg.CMD_ITEM);
    var btnItem = new MyButton(0, 0, lblItem, function() {
      // インベントリ表示
      _displayInventoryUI(actor);
    });
    if(Inventory.isEmpty()) {
      // アイテムがないので選べない
      btnItem.enable = false;
    }
    btnList.add(btnItem);

    // 逃走
    var lblEscape = UIMsg.get(UIMsg.CMD_ESCAPE);
    btnList.add(new MyButton(0, 0, lblEscape, function() {
      cbFunc(actor, BtlCmd.Escape(true));
    }));

    // ボタンの登録と座標の調整
    var px = BTN_X;
    var py = BTN_Y;
    var idx = 0;
    for(btn in btnList) {
      // 登録
      this.add(btn);
      // 座標を調整
      btn.x = px;
      btn.y = py;
      // スクロール無効
      btn.scrollFactor.set();
      px += BTN_DX;
      idx++;
      if(idx%3 == 0) {
        // 次の行
        px = BTN_X;
        py += BTN_DY;
      }
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
  private function _skill(actor:Actor, cbFunc:Actor->BtlCmd->Void, skill:SkillData):Void {

    // 対象グループ取得
    var group = BtlGroupUtil.getAgaint(actor.group);
    // 攻撃対象範囲
    var range = SkillUtil.toRange(skill.id);

    // バトル用の範囲
    var btlRange = SkillUtil.rangeToBtlRange(range);

    BtlTargetUI.open(function(targetID) {
      if(targetID == BtlTargetUI.CMD_CANCEL) {
        // キャンセルした
        _display();
        visible = true;
        return;
      }
      // スキル使用
      cbFunc(actor, BtlCmd.Skill(skill.id, btlRange, targetID));
    }, group, btlRange);

    visible = false;
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
