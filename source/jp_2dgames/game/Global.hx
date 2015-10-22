package jp_2dgames.game;

import jp_2dgames.game.shop.ShopData;
import jp_2dgames.game.skill.SkillSlot;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.item.ItemConst;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.PlayerInfo;

/**
 * グローバル情報
 **/
class Global {
  static inline var STAGE_FIRST:Int = 1;
  static inline var MONEY_FIRST:Int = 100;

  // ■スタティック変数
  static var _bLoad:Bool = false;
  static var _playerParam:Params = null;
  static var _playerName:String = "プレイヤー";
  static var _enemyGroup:Int = 0;
  static var _itemList:Array<ItemData> = null;
  static var _money:Int = 0;
  static var _floor:Int = 0;
  static var _skillList:Array<SkillData> = null;
  static var _shop:ShopData = null;

  // デバッグ用
  static var _bTestBattle:Bool = false;

  /**
   * 初期化
   **/
  public static function init():Void {

    // ロードフラグ初期化
    _bLoad = false;

    // プレイヤー情報の初期化
    _initPlayer();

    // インベントリの初期化
    _initInventory();

    // 敵グループ番号初期化
    _enemyGroup = 1;

    // 所持金を初期化
    _money = MONEY_FIRST;

    // フロア番号を初期化
    _floor = 1;

    // デバッグフラグ
    _bTestBattle = false;

    // ショップ情報
    _shop = new ShopData();
  }

  /**
   * ロードフラグを立てる
   **/
  public static function setLoadFlag(b:Bool):Void {
    _bLoad = b;
  }
  // ロードフラグが立っているかどうか
  public static function isLoad():Bool {
    return _bLoad;
  }

  // プレイヤー情報の初期化
  private static function _initPlayer():Void {

    // パラメータ生成
    _playerParam = new Params();
    var lv:Int = 1;
    PlayerInfo.setParam(_playerParam, lv);

    // スキル初期化
    _skillList = new Array<SkillData>();
    SkillSlot.create(_skillList);
  }

  // プレイヤー情報の取得
  public static function getPlayerParam():Params {
    return _playerParam;
  }
  // プレイヤーパラメータの設定
  public static function setPlayerParam(param:Params):Void {
    _playerParam.copy(param);
  }
  // プレイヤー名の取得
  public static function getPlayerName():String {
    return _playerName;
  }

  // スキルスロットの取得
  public static function getSkillSlot():Array<SkillData> {
    return _skillList;
  }

  // スキルスロットの設定
  public static function setSkillSlot(slot:Array<SkillData>):Void {
    _skillList = slot;
  }

  // 敵グループ番号の取得
  public static function getEnemyGroup():Int {
    return _enemyGroup;
  }
  // 敵グループ番号の設定
  public static function setEnemyGroup(val:Int):Void {
    _enemyGroup = val;
  }

  // インベントリの初期化
  private static function _initInventory():Void {
    _itemList = new Array<ItemData>();

    Inventory.create(_itemList);

    // 初期アイテム
    Inventory.push(new ItemData(ItemConst.POTION01));
  }

  // アイテムリストを設定
  public static function setItemList(array:Array<ItemData>):Void {
    _itemList = array;
    Inventory.create(_itemList);
  }

  // 所持金を取得する
  public static function getMoney():Int {
    return _money;
  }
  // 所持金を増やす
  public static function addMoney(val:Int):Void {
    _money += val;
  }
  // 所持金を減らす
  public static function useMoney(val:Int):Void {
    _money -= val;
  }
  // 所持金の設定
  public static function setMoney(val:Int):Void {
    _money = val;
  }

  // フロア数を取得する
  public static function getFloor():Int {
    return _floor;
  }

  // フロア数を設定する
  public static function setFloor(v:Int):Void {
    _floor = v;
  }

  // フロア数を進める
  public static function nextFloor():Bool {
    if(isFloorMax()) {
      return false;
    }

    _floor++;

    return true;
  }

  // フロア数が最大かどうか
  public static function isFloorMax():Bool {
    return false;
  }

  // ショップ情報の取得
  public static function getShopData():ShopData {
    return _shop;
  }

  // ショップ情報の設定
  public static function setShopData(data:ShopData):Void {
    _shop = data;
  }


  // ------------------------------------------
  // ■デバッグ用
  public static function isTestBattle():Bool {
    return _bTestBattle;
  }
  public static function setTestBattle(b:Bool):Void {
    _bTestBattle = b;
  }
}
