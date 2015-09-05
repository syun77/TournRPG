package jp_2dgames.game.item;

/**
 * インベントリ
 **/
class Inventory {

  // アイテム所持最大数
  private static inline var LIMIT_FIRST:Int = 8;

  // ■static変数
  // シングルトン
  private static var _instance:Inventory = null;

  // ■static関数
  /**
   * 生成
   **/
  public static function create(itemList:Array<ItemData>) {
    if(_instance == null) {
      _instance = new Inventory(itemList);
    }
  }

  /**
   * 破棄
   **/
  public static function destroy() {
    _instance = null;
  }

  /**
   * インベントリにアイテムを追加する
   **/
  public static function push(itemData:ItemData):Void {
    _instance._push(itemData);
  }

  /**
   * アイテム所持内容に何か変更があったかどうか
   **/
  public static function isDirty():Bool {
    return _instance._dirty;
  }
  /**
   * 変更点を解消した
   **/
  public static function resolveDirty():Void {
    _instance._dirty = false;
  }

  // ================================================
  // ■以下インスタンス変数
  // ================================================

  // アイテムリスト
  var _itemList:Array<ItemData>;
  public var itemList(get, never):Array<ItemData>;
  private function get_itemList() {
    return _itemList;
  }

  // アイテム所持最大数
  var _limit:Int = LIMIT_FIRST;

  // アイテム所持内容に何か変化があったかどうか
  var _dirty:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new(itemList:Array<ItemData>) {
    _itemList = itemList;
  }

  /**
   * アイテム所持数を取得する
   **/
  public function countItem():Int {
    return itemList.length;
  }

  /**
   * アイテム所持数が最大に達しているかどうか
   **/
  public function isFull():Bool {
    return countItem() >= _limit;
  }

  /**
   * アイテムを何も所持していないかどうか
   **/
  public function isEmpty():Bool {
    return countItem() == 0;
  }

  /**
   * アイテムを追加
   **/
  private function _push(itemData:ItemData):Void {
    if(isFull()) {
      // アイテムが最大なので追加できない
      return;
    }

    _itemList.push(itemData);
    _dirty = true;
  }
}
