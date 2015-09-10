package jp_2dgames.game;

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
  static inline var MONEY_FIRST:Int = 0;

  // ■スタティック変数
  static var _playerParam:Params = null;
  static var _stage:Int = 0;
  static var _itemList:Array<ItemData> = null;
  static var _money:Int = 0;

  public static function init():Void {

    // プレイヤー情報の初期化
    _initPlayer();

    // インベントリの初期化
    _initInventory();

    // ステージ初期化
    _stage = STAGE_FIRST;

    // 所持金を初期化
    _money = MONEY_FIRST;
  }

  // プレイヤー情報の初期化
  private static function _initPlayer():Void {
    _playerParam = new Params();
    PlayerInfo.setParam(_playerParam, 1);
  }

  // プレイヤー情報の取得
  public static function getPlayerParam():Params {
    return _playerParam;
  }
  public static function setPlayerHp(hp:Int):Void {
    _playerParam.hp = hp;
  }

  // ステージ番号の取得
  public static function getStage():Int {
    return _stage;
  }
  public static function nextStage():Void {
    _stage++;
  }

  // インベントリの初期化
  private static function _initInventory():Void {
    _itemList = new Array<ItemData>();

    Inventory.create(_itemList);

    // 初期アイテム
    Inventory.push(new ItemData(ItemConst.POTION01));
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
}
