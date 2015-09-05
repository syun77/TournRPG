package jp_2dgames.game.item;

import jp_2dgames.lib.CsvLoader;

/**
 * アイテム種別
 **/
enum IType {
  None;   // なし
  Potion; // ポーション
  Weapon; // 武器
  Armor;  // よろい
  Ring;   // 指輪
}

/**
 * アイテムユーティリティ
 **/
class ItemUtil {
  // 無効なアイテム番号
  public static inline var NONE = -1;
  private static inline var ID_OFFSET:Int = 1000;

  // アイテムデータを定義しているCSV
  private static var _csvConsumable:CsvLoader = null;
  private static var _csvEquipment:CsvLoader  = null;
  private static var _typeTbl:Map<String,IType>;

  /**
   * CSVファイルを読み込む
   **/
  public static function load():Void {
    _csvConsumable = new CsvLoader(Reg.PATH_CSV_ITEM_CONSUMABLE);
    _csvEquipment  = new CsvLoader(Reg.PATH_CSV_ITEM_EQUIPMENT);
    _typeTbl = [
      toString(IType.None)   => IType.None,
      toString(IType.Potion) => IType.Potion,
      toString(IType.Weapon) => IType.Weapon,
      toString(IType.Armor)  => IType.Armor,
      toString(IType.Ring)   => IType.Ring
    ];
  }

  /**
   * 破棄
   **/
  public static function unload():Void {
    _csvConsumable = null;
    _csvEquipment  = null;
  }

  /**
   * CSVデータを取得する
   **/
  public static function getCsv(itemID:Int):CsvLoader {
    if(isConsumable(itemID)) {
      // 消耗品
      return _csvConsumable;
    }
    else {
      // 装備品
      return _csvEquipment;
    }
  }

  /**
   * 消耗品かどうか
   **/
  public static function isConsumable(itemID:Int):Bool {
    if(itemID < ID_OFFSET) {
      return true;
    }
    else {
      return false;
    }
  }

  /**
   * 装備品かどうか
   **/
  public static function isEquip(itemID:Int):Bool {
    return isConsumable(itemID) == false;
  }

  /**
   * パラメータを取得する
   **/
  public static function getParam(itemID:Int, key:String):Int {
    var csv = getCsv(itemID);
    return csv.searchItemInt("id", '${itemID}', key, false);
  }
  public static function getParamString(itemID:Int, key:String):String {
    var csv = getCsv(itemID);
    return csv.searchItem("id", '${itemID}', key);
  }

  /**
   * アイテム種別変換
   **/
  public static function toString(type:IType):String {
    return '${type}';
  }
  public static function fromString(str:String):IType {
    return _typeTbl[str];
  }

  /**
   * アイテムIDからアイテム種別を求める
   **/
  public static function toType(itemID:Int):IType {
    var csv = getCsv(itemID);
    var str = csv.searchItem("id", '${itemID}', "type", false);
    if(str == "") {
      // 無効なアイテム
      return IType.None;
    }

    return fromString(str);
  }
}
