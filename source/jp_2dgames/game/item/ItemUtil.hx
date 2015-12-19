package jp_2dgames.game.item;

import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.actor.Actor;
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
  public static inline var NONE:Int = -1;
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
   * バトル中に使えるかどうか
   **/
  public static function isAvailableBattle(itemID:Int):Bool {
    switch(getParamString(itemID, "available")) {
      case "BOTH", "BATTLE":
        return true;
      default:
        return false;
    }
  }

  /**
   * フィールドで使えるかどうか
   **/
  public static function isAvailableField(itemID:Int):Bool {
    switch(getParamString(itemID, "available")) {
      case "BOTH", "FIELD":
        return true;
      default:
        return false;
    }
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
   * アイテム名を取得する
   **/
  public static function getName(item:ItemData):String {
    return getParamString(item.id, "name");
  }
  // 攻撃力
  public static function getAtk(item:ItemData):Int {
    return getParam(item.id, "atk");
  }
  // 守備力
  public static function getDef(item:ItemData):Int {
    return getParam(item.id, "def");
  }
  // 詳細
  public static function getDetail(item:ItemData):String {
    return getParamString(item.id, "detail");
  }
  // 購入価格
  public static function getBuy(item:ItemData):Int {
    return getParam(item.id, "buy");
  }
  // 売却価格
  public static function getSell(item:ItemData):Int {
    return getParam(item.id, "sell");
  }
  // 特殊効果
  public static function getExtra(item:ItemData):String {
    return getParamString(item.id, "extra");
  }
  // 特殊効果パラメータ
  public static function getExtVal(item:ItemData):Int {
    return getParam(item.id, "extval");
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

  /**
   * アイテムを使う
   * @param actor 主体者
   * @param item  アイテム情報
   * @param bMsg  使用メッセージを表示するかどうか
   **/
  public static function use(actor:Actor, item:ItemData, bMsg:Bool=true):Void {

    var extra = getExtra(item);
    var extval = getExtVal(item);

    switch(item.type) {
      case IType.Potion:
        // 薬
        var val = ItemUtil.getParam(item.id, "hp");
        if(val > 0) {
          actor.recoverHp(val);
          if(bMsg) {
            Message.push2(Msg.RECOVER_HP, [actor.name, val]);
          }
        }
        if(extra != "") {
          // 特殊効果あり
          useExtra(actor, extra, extval);
        }

        Snd.playSe("recover");

      default:
        // 何も起きない
    }
  }

  /**
   * アイテムを使う（特殊効果）
   * @param actor    主体者
   * @param extra    特殊効果
   * @param extraVal 特殊効果パラメータ
   **/
  public static function useExtra(actor:Actor, extra:String, extval:Int):Void {

    switch(extra) {
      case "hpmax":
        // 最大HP上昇
        actor.addHpMax(extval);
        Message.push2(Msg.GROW_HPMAX, [actor.name, extval]);

      case "str":
        // 力上昇
        actor.addStr(extval);
        Message.push2(Msg.GROW_STR, [actor.name, extval]);
      case "vit":
        // 体力上昇
        actor.addVit(extval);
        Message.push2(Msg.GROW_VIT, [actor.name, extval]);
      case "agi":
        // 素早さ上昇
        actor.addAgi(extval);
        Message.push2(Msg.GROW_AGI, [actor.name, extval]);
      case "mag":
        // 魔力上昇
        actor.addMag(extval);
        Message.push2(Msg.GROW_MAG, [actor.name, extval]);
    }
  }
}
