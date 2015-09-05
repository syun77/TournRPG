package jp_2dgames.game.item;

import jp_2dgames.game.item.ItemUtil;

/**
 * アイテム情報
 **/
class ItemData {

  public var id:Int       = ItemUtil.NONE; // アイテムID
  public var type:IType   = IType.None;    // アイテム種別
  public var isEquip:Bool = false;         // 装備しているかどうか

  public function new() {
  }
}
