package jp_2dgames.game.btl;

import jp_2dgames.lib.Snd;
import flixel.FlxState;
import jp_2dgames.game.item.ItemConst;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.lib.Input;
import flixel.FlxG;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.gui.UIMsg;
import jp_2dgames.game.gui.Dialog;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.btl.BtlGroupUtil;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.ActorMgr;

/**
 * 状態
 **/
private enum State {
  Money;         // お金
  Xp;            // 経験値
  Levelup;       // レベルアップチェック
  Pickup;        // アイテムを拾う
  PickupCheck;   // アイテム拾えるかチェック
  CantGet;       // アイテムが一杯で拾えない
  CantGetDialog; // アイテムが一杯で拾えなかったダイアログ
  ItemDel;       // アイテムを捨てる
  ItemDelUI;     // アイテムを捨てるUI表示中
  End;           // 終了
}

/**
 * 落としたアイテムの情報
 **/
private class ItemDropInfo {
  public var name:String;   // 敵の名前
  public var item:ItemData; // アイテム情報
  public function new(name, item) {
    this.name = name;
    this.item = item;
  }
}

/**
 * リザルト制御
 **/
class BtlResult {

  // ■メンバ変数
  // 状態
  var _state:State = State.Money;

  // 停止タイマー
  var _tWait:Int = 0;

  // 獲得したお金
  var _money:Int = 0;

  // 獲得した経験値
  var _xp:Int = 0;

  // 獲得したアイテム
  var _infos:List<ItemDropInfo>;

  // 現在処理するアイテム
  var _nowInfo:ItemDropInfo = null;

  var _flxState:FlxState;

  /**
   * コンストラクタ
   **/
  public function new(flxState:FlxState) {

    _flxState = flxState;

    // アイテム入手
    _money = 0;
    _xp    = 0;
    _infos = new List<ItemDropInfo>();
    ActorMgr.forEachGrave(function(actor:Actor) {
      if(actor.group == BtlGroup.Enemy) {
        // お金
        _money += actor.money;

        // 経験値
        _xp += actor.xp;

        // アイテム
        // TODO:
//        var item = new ItemData(ItemConst.POTION01);
//        var info = new ItemDropInfo(actor.name, item);
//        _infos.push(info);
      }
    });

  }

  /**
   * キー入力待ちであるかどうかをチェックする
   **/
  private function _checkWait():Bool {
    if(_tWait > 0) {
      _tWait--;
      if(Input.press.A) {
        // 演出ウェイトスキップ
        _tWait = 0;
      }
      if(_tWait > 0) {
        // 停止中
        return true;
      }
    }

    // 停止しない
    return false;
  }

  /**
   * 更新
   **/
  public function update():Void {

    if(_checkWait()) {
      // 停止中
      return;
    }

    switch(_state) {
      case State.Money:
        // お金
        Global.addMoney(_money);
        Snd.playSe("coin");
        var str = '${_money}G';
        Message.push2(Msg.ITEM_GET, [str]);
        _tWait = Reg.TIMER_WAIT;
        _state = State.Xp;

      case State.Xp:
        // 経験値
        ActorMgr.forEachAliveGroup(BtlGroup.Player, function(actor:Actor) {
          // 経験値加算
          actor.addXp(_xp);
        });
        Message.push2(Msg.XP_GET, [_xp]);
        _tWait = Reg.TIMER_WAIT;
        _state = State.Levelup;

      case State.Levelup:
        // レベルアップチェック
        var bLevelup = false;
        ActorMgr.forEachAliveGroup(BtlGroup.Player, function(actor:Actor) {
          if(actor.checkLevelup()) {
            // レベルアップした
            bLevelup = true;
            Message.push2(Msg.LEVELUP, [actor.name]);
            // HP全回復
            actor.recoverHp(9999);
            Message.push2(Msg.RECOVER_HP_ALL, [actor.name]);

            Snd.playSe("levelup");
          }
        });
        if(bLevelup) {
          // レベルアップした
          _tWait = Reg.TIMER_WAIT;
        }
        _state = State.Pickup;

      case State.Pickup:
        _nowInfo = _infos.pop();
        if(_nowInfo == null) {
          // 拾えるアイテムがないのでおしまい
          _state = State.End;
          return;
        }

        // アイテム名
        var name = ItemUtil.getName(_nowInfo.item);

        // ドロップメッセージの表示
        Message.push2(Msg.ITEM_DROP, [_nowInfo.name, name]);
        _tWait = Reg.TIMER_WAIT;
        _state = State.PickupCheck;

      case State.PickupCheck:
        // アイテム名
        var name = ItemUtil.getName(_nowInfo.item);
        if(Inventory.isFull()) {
          // アイテムが一杯で拾えない
          Message.push2(Msg.ITEM_CANT_GET, [name]);
          _state = State.CantGet;
          _tWait = Reg.TIMER_WAIT*3;
        }
        else {
          // 拾えたので次へ進む
          Inventory.push(_nowInfo.item);
          Message.push2(Msg.ITEM_GET, [name]);
          _state = State.Pickup;
        }

      case State.CantGet:
        // アイテムが拾えない
        var name = ItemUtil.getName(_nowInfo.item);

        // YES/NOダイアログ表示
        var msg = UIMsg.get2(UIMsg.ITEM_CHANGE, [name]);
        Dialog.open(_flxState, Dialog.YESNO, msg, null, function(btnID:Int) {
          if(btnID == Dialog.BTN_YES) {
            // アイテムを捨てて拾う
            Message.push2(Msg.ITEM_SEL_DEL);
            _state = State.ItemDel;
          }
          else {
            // アイテムをあきらめる
            Message.push2(Msg.ITEM_ABANDAN, [name]);
            _state = State.Pickup;
          }
        });
        _state = State.CantGetDialog;

      case State.CantGetDialog:

      case State.ItemDel:
        // アイテムを捨てて拾う
        var ui = null;
        ui = new InventoryUI(function(idx:Int) {
          if(idx == InventoryUI.CMD_CANCEL) {
            // キャンセル
            _state = State.CantGet;
            return;
          }

          var item = Inventory.getItem(idx);
          var name = ItemUtil.getName(item);
          var name2  = ItemUtil.getName(_nowInfo.item);
          Inventory.delItem(idx);
          Inventory.push(_nowInfo.item);
          Message.push2(Msg.ITEM_DEL_GET, [name, name2]);
          _flxState.remove(ui);

          // 次のアイテムを見る
          _state = State.Pickup;
        }, null);
        _flxState.add(ui);

        _state = State.ItemDelUI;

      case State.ItemDelUI:

      case State.End:
    }
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }
}
