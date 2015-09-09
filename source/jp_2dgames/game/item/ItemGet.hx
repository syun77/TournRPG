package jp_2dgames.game.item;

import flixel.FlxG;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.gui.UIMsg;
import jp_2dgames.game.gui.Dialog;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.ActorMgr;

/**
 * 状態
 **/
private enum State {
  Pickup;    // アイテムを拾う
  CantGetDialog; // アイテムが一杯で拾えなかった
  ItemDel; // アイテムを捨てる
  ItemDelUI; // アイテムを捨てるUI表示中
  End;     // 終了
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
 * アイテム入手
 **/
class ItemGet {

  // 状態
  var _state:State = State.Pickup;

  // 獲得したアイテム
  var _infos:List<ItemDropInfo>;

  // 現在処理するアイテム
  var _nowInfo:ItemDropInfo = null;

  /**
   * コンストラクタ
   **/
  public function new() {
    // アイテム入手
    _infos = new List<ItemDropInfo>();
    ActorMgr.forEachGrave(function(actor:Actor) {
      if(actor.group == BtlGroup.Enemy) {
        var item = new ItemData(ItemConst.POTION01);
        var info = new ItemDropInfo(actor.name, item);
        _infos.push(info);
      }
    });

    if(_infos.length > 0) {
      // アイテムを拾う処理へ
      _state = State.Pickup;
    }
    else {
      // アイテムなし
      _state = State.End;
    }
  }

  /**
   * 更新
   **/
  public function update():Void {
    switch(_state) {
      case State.Pickup:
        _nowInfo = _infos.pop();
        if(_nowInfo == null) {
          // おしまい
          _state = State.End;
          return;
        }

        // アイテム名
        var name = ItemUtil.getName(_nowInfo.item);

        // ドロップメッセージの表示
        Message.push2(Msg.ITEM_DROP, [_nowInfo.name, name]);

        if(Inventory.isFull()) {
          // アイテムが一杯で拾えない
          Message.push2(Msg.ITEM_CANT_GET, [name]);

          // YES/NOダイアログ表示
          var msg = UIMsg.get2(UIMsg.ITEM_CHANGE, [name]);
          Dialog.open(Dialog.YESNO, msg, null, function(btnID:Int) {
            if(btnID == Dialog.BTN_YES) {
              // アイテムを捨てて拾う
              _state = State.ItemDel;
            }
            else {
              // アイテムをあきらめる
              Message.push2(Msg.ITEM_ABANDAN, [name]);
              _state = State.End;
            }
            _state = State.ItemDel;
          });
          _state = State.CantGetDialog;
        }
        else {
          // 拾えたので次へ進む
          _state = State.Pickup;
        }

      case State.CantGetDialog:

      case State.ItemDel:
        // アイテムを捨てて拾う
        var ui = null;
        ui = new InventoryUI(function(idx:Int) {
          if(idx == InventoryUI.CMD_CANCEL) {
            // キャンセル
            _state = State.End;
            return;
          }

          var item = Inventory.getItem(idx);
          var name = ItemUtil.getName(item);
          var name2  = ItemUtil.getName(_nowInfo.item);
          Inventory.delItem(idx);
          Inventory.push(_nowInfo.item);
          Message.push2(Msg.ITEM_DEL_GET, [name, name2]);
          FlxG.state.remove(ui);

          // 次のアイテムを見る
          _state = State.Pickup;
        }, null);
        FlxG.state.add(ui);

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
