package jp_2dgames.game.item;

import jp_2dgames.game.item.ItemUtil.IType;
import jp_2dgames.game.actor.Actor;

/**
 * インベントリ
 **/
class Inventory {

  // アイテム所持最大数
  private static inline var LIMIT_FIRST:Int = 16;

  // ■static変数
  // シングルトン
  private static var _instance:Inventory = null;

  // ■static関数
  /**
   * 生成
   **/
  public static function create(itemList:Array<ItemData>) {
    _instance = new Inventory(itemList);
  }

  /**
   * 破棄
   **/
  public static function destroy() {
    _instance = null;
  }

  /**
   * アイテムリストを設定する
   **/
  public static function setItemList(itemList:Array<ItemData>) {
    _instance._init(itemList);
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

  /**
   * アイテムリストを取得する
   **/
  public static function getItemList():Array<ItemData> {
    return _instance.itemList;
  }

  /**
   * 所持しているアイテムの数を取得する
   **/
  public static function lengthItemList():Int {
    return _instance.itemList.length;
  }

  /**
   * インデックスをUIDに変換する
   **/
  public static function idxToUID(idx:Int):Int {
    return _instance._idxToUID(idx);
  }

  /**
   * アイテムを取得する
   **/
  public static function getItem(uid:Int):ItemData {
    return _instance._getItem(uid);
  }

  /**
   * アイテムを削除する
   **/
  public static function delItem(uid:Int):Void {
    _instance._delItem(uid);
  }

  /**
   * アイテムを何も所持していないかどうか
   **/
  public static function isEmpty():Bool {
    return _instance._isEmpty();
  }

  /**
   * アイテムが一杯かどうか
   **/
  public static function isFull():Bool {
    return _instance._isFull();
  }

  /**
   * 装備している武器を取得する
   **/
  public static function getWeapon():ItemData {
    return _instance.weapon;
  }
  /**
   * 装備している防具を取得する
   **/
  public static function getArmor():ItemData {
    return _instance.armor;
  }
  /**
   * 装備している指輪を取得する
   **/
  public static function getRing():ItemData {
    return _instance.ring;
  }

  /**
   * 指定のアイテムを装備する
   **/
  public static function equip(uid:Int):Void {
    _instance._equip(uid);
  }

  /**
   * アイテム情報をデバッグ出力する
   **/
  public static function dumpItemList():Void {
    _instance._dumpItemList();
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

  // ■装備アイテム
  var _equipNull:ItemData = null;
  // 武器
  public var weapon(get, never):ItemData;
  private function get_weapon() {
    return _getEquipFromType(IType.Weapon);
  }
  // 防具
  public var armor(get, never):ItemData;
  private function get_armor() {
    return _getEquipFromType(IType.Armor);
  }
  // 指輪
  public var ring(get, never):ItemData;
  private function get_ring() {
    return _getEquipFromType(IType.Ring);
  }

  /**
   * コンストラクタ
   **/
  public function new(itemList:Array<ItemData>) {
    _init(itemList);
  }

  /**
   * 初期化
   **/
  private function _init(itemList:Array<ItemData>):Void {
    _itemList = itemList;

    // 何も装備していないときに返却するNULLオブジェクト
    _equipNull = new ItemData();
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
  private function _isFull():Bool {
    return countItem() >= _limit;
  }

  /**
   * アイテムを何も所持していないかどうか
   **/
  private function _isEmpty():Bool {
    return countItem() == 0;
  }

  /**
   * UIDを更新する
   **/
  private function _refreshUID():Void {
    var idx = 0;
    for(item in _itemList) {
      item.uid = 1000 + idx;
      idx++;
    }
  }

  /**
   * アイテムを追加
   * ※複製コピーする
   **/
  private function _push(itemData:ItemData):Void {
    if(_isFull()) {
      // アイテムが最大なので追加できない
      return;
    }

    // 複製して追加する
    _itemList.push(itemData.clone());
    _dirty = true;

    // UIDを更新
    _refreshUID();
  }

  /**
   * アイテムを削除する
   **/
  private function _delItem(uid:Int):Void {

    // アイテムリストから削除
    var item = _getItem(uid);
    itemList.remove(item);
//    itemList.splice(idx, 1);

    _dirty = true;
  }

  private function _idxToUID(idx:Int):Int {
    return itemList[idx].uid;
  }

  private function _getItem(uid:Int):ItemData {

    for(item in itemList) {
      if(uid == item.uid) {
        return item;
      }
    }

    return null;
  }

  /**
   * アイテムを装備する
   **/
  private function _equip(uid:Int):Void {

    var item = getItem(uid);
    if(item.isEquip) {
      // すでに装備済みであれば何もしない
      return;
    }

    // 指定のカテゴリの装備を外す
    _unequip(item.type);

    // 指定のアイテムを装備する
    item.isEquip = true;
  }

  /**
   * 指定のタイプの装備品を取得する
   **/
  private function _getEquipFromType(type:IType):ItemData {
    for(item in itemList) {
      if(item.type == type) {
        if(item.isEquip) {
          return item;
        }
      }
    }

    // 装備品なし
    return _equipNull;
  }

  /**
   * 装備品を外す
   **/
  private function _unequip(type:IType):Void {
    var item = _getEquipFromType(type);
    item.isEquip = false;
  }

  /**
   * アイテム情報をデバッグ出力する
   **/
  private function _dumpItemList():Void {
    trace("## Iventory.ItemList Dump.");
    var idx = 0;
    for(item in itemList) {
      trace(idx, item);
      idx++;
    }
  }
}
