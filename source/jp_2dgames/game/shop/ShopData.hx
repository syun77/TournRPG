package jp_2dgames.game.shop;
import jp_2dgames.game.item.ItemConst;
import jp_2dgames.game.item.ItemData;

/**
 * ショップデータ
 **/
class ShopData {

  var _itemList:Array<ItemData>;
  public var itemList(get, never):Array<ItemData>;
  function get_itemList() {
    return _itemList;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    _itemList = new Array<ItemData>();

    // TODO: 仮データ追加
    var item = new ItemData(ItemConst.POTION01);
    _itemList.push(item);
  }

}
