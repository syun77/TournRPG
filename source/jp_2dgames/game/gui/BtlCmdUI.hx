package jp_2dgames.game.gui;
import flixel.util.FlxDestroyUtil;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.skill.SkillRange;
import flixel.FlxState;
import flixel.ui.FlxButton;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.skill.SkillSlot;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.btl.BtlGroupUtil;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
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
  private static inline var BTN_DX = MyButton2.WIDTH + Reg.BTN_OFS_DX;
  private static inline var BTN_DY = MyButton2.HEIGHT + Reg.BTN_OFS_DY;

  // ■メンバ変数

  // アイテム選択用のコールバック関数
  private var _cbItem:Int->Void = null;

  // コマンド詳細
  private var _detailUI:DetailUI;

  // ボタン
  private var _btnList:List<MyButton2>;

  private var _state:FlxState;

  /**
   * コンストラクタ
   * @param actor 行動主体者
   * @param cbFunc コマンド実行コールバック関数
   **/
  public function new(state:FlxState, actor:Actor, cbFunc:Actor->BtlCmd->Void) {

    _state = state;

    // アイテム選択のコール関数を登録しておく
    _cbItem = function(uid:Int) {

      // アイテム取得
      var item = Inventory.getItem(uid);

      // 使用を予約
      item.bReserved = true;

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
    _btnList = new List<MyButton2>();
    var lblAtk = UIMsg.get(UIMsg.CMD_ATK);
    _btnList.add(new MyButton2(0, 0, lblAtk, function() {
      _attack(actor, cbFunc);
    }));

    //  スキル
    for(idx in 0...SkillSlot.count()) {
      var skill = SkillSlot.getSkill(idx);
      if(SkillUtil.isNormal(skill.id) == false) {
        // パッシブスキルは選べない
        continue;
      }
      var name = SkillUtil.getName(skill.id);
      var btn = new MyButton2(0, 0, name, function() {
        _skill(actor, cbFunc, skill);
      });
      // コストチェック
      btn.enabled = SkillUtil.checkCost(skill.id, actor);
      // スキル説明
      btn.detail = SkillUtil.getDetail2(skill.id);
      _btnList.add(btn);
    }

    // アイテム
    var lblItem = UIMsg.get(UIMsg.CMD_ITEM);
    var btnItem = new MyButton2(0, 0, lblItem, function() {
      // インベントリ表示
      _displayInventoryUI(actor);
    });
    if(Inventory.isEmpty()) {
      // アイテムがないので選べない
      btnItem.enabled = false;
    }
    _btnList.add(btnItem);

    // 逃走
    var lblEscape = UIMsg.get(UIMsg.CMD_ESCAPE);
    _btnList.add(new MyButton2(0, 0, lblEscape, function() {
      cbFunc(actor, BtlCmd.Escape(true));
    }));

    // ボタンの登録と座標の調整
    var px = BTN_X;
    var py = BTN_Y;
    var idx = 0;
    for(btn in _btnList) {
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

    // コマンド詳細
    _detailUI = new DetailUI();
    state.add(_detailUI);

    // 非表示にしておく
    _detailUI.visible = false;
  }

  override public function destroy():Void {
    super.destroy();

    _detailUI = FlxDestroyUtil.destroy(_detailUI);
  }

  /**
   * 消滅
   **/
  public function vanish(state:FlxState):Void {
    // コマンド詳細を消す
    state.remove(_detailUI);

    // 破棄
    destroy();
  }

  /**
   * 攻撃コマンドを選んだ
   **/
  private function _attack(actor:Actor, cbFunc:Actor->BtlCmd->Void):Void {
    var group = BtlGroupUtil.getAgaint(actor.group);
    var range = BtlRange.One;

    BtlTargetUI.open(_state, function(targetID) {
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

    // 攻撃対象範囲
    var range = SkillUtil.toRange(skill.id);

    // 自分自身が対象かどうかチェック
    var bSelf = false;
    switch(range) {
      case SkillRange.Self, SkillRange.FriendOne, SkillRange.FriendAll:
        // 自分自身
        bSelf = true;

      default:
        // 敵が対象
        bSelf = false;
    }

    if(bSelf) {
      // 自分自身
      // バトル用の範囲
      var btlRange = SkillUtil.rangeToBtlRange(range);
      cbFunc(actor, BtlCmd.Skill(skill.id, btlRange, actor.ID));
    }
    else {
      // 敵が対象
      _skillTargetEnemy(actor, cbFunc, skill);
    }

    visible = false;
  }

  private function _skillTargetEnemy(actor:Actor, cbFunc:Actor->BtlCmd->Void, skill:SkillData):Void {

    // 対象グループ取得
    var group = BtlGroupUtil.getAgaint(actor.group);
    // 攻撃対象範囲
    var range = SkillUtil.toRange(skill.id);

    // バトル用の範囲
    var btlRange = SkillUtil.rangeToBtlRange(range);

    BtlTargetUI.open(_state, function(targetID) {
      if(targetID == BtlTargetUI.CMD_CANCEL) {
        // キャンセルした
        _display();
        visible = true;
        return;
      }
      // スキル使用
      cbFunc(actor, BtlCmd.Skill(skill.id, btlRange, targetID));
    }, group, btlRange);

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
    var param = new InventoryUIParam(InventoryUI.MODE_NORMAL);
    param.call = InventoryUIParam.CALL_BATTLE;
    InventoryUI.open(_state, _cbItemSelect, actor, param);
    // 自身は非表示
    visible = false;
  }

  /**
   * アイテム選択のコールバック関数
   **/
  private function _cbItemSelect(result:InventoryUIResult):Void {

    if(result.uid == InventoryUI.CMD_CANCEL) {
      // キャンセルしたのでコマンドUIを再び表示
      _display();
      return;
    }

    // アイテムを選んだ
    _cbItem(result.uid);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // ボタンの状態を調べる
    for(btn in _btnList) {
      switch(btn.status) {
        case FlxButton.HIGHLIGHT, FlxButton.PRESSED:
          _detailUI.visible = true;

          // 表示情報を更新
          var detail = btn.detail;
          if(detail == "") {
            continue;
          }
          _detailUI.setText(detail);
          return;
      }
    }

    // ボタンを選択していないので非表示
    _detailUI.visible = false;
  }
}
