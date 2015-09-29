package jp_2dgames.game.item;

import jp_2dgames.game.item.ItemUtil;

/**
 * アイテム情報
 **/
class ItemData {

  public var id:Int         = ItemUtil.NONE; // アイテムID
  public var type:IType     = IType.None;    // アイテム種別
  public var isEquip:Bool   = false;         // 装備しているかどうか
  public var uid:Int        = 0;             // ユニーク番号 (インベントリ内での管理に使用)
  public var bReserved      = false;         // 使用を予約 (複数人が使えないようにするためのもの)

  /**
   * コンストラクタ
   * @param itemID アイテムID
   **/
  public function new(itemID:Int=ItemUtil.NONE) {
    if(itemID == ItemUtil.NONE) {
      return;
    }

    setItemID(itemID);
  }

  /**
   * アイテムIDを設定
   **/
  public function setItemID(itemID:Int):Void {
    id   = itemID;
    type = ItemUtil.toType(itemID);
  }

  /**
   * コピー
   **/
  public function copy(itemData:ItemData):Void {
    id      = itemData.id;
    type    = itemData.type;
    isEquip = itemData.isEquip;
  }

  /**
   * 複製
   **/
  public function clone():ItemData {
    var data = new ItemData();
    data.copy(this);
    return data;
  }
}
