package jp_2dgames.game.save;

import jp_2dgames.game.actor.PartyMgr;
import jp_2dgames.game.field.FieldEffectUtil;
import jp_2dgames.game.shop.ShopData;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.field.TmpFieldFoe;
import flixel.util.FlxSave;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.field.FieldFoe;
import jp_2dgames.game.field.TmpFieldNode;
import jp_2dgames.game.field.FieldNode;
import jp_2dgames.game.field.FieldEvent;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.Reg;
import haxe.Json;

// グローバル
private class _Global {
  public var enemyGroup:Int; // 敵グループ番号
  public var money:Int;      // 所持金
  public var floor:Int;      // フロア数
  public function new() {
  }
  // セーブ
  public function save() {
    money      = Global.getMoney();
    floor      = Global.getFloor();
  }
  // ロード
  public function load(data:Dynamic) {
    Global.setMoney(data.money);
    Global.setFloor(data.floor);
  }
}

// パーティ情報
private class _Party {
  public var array:Array<Params>;
  public function new() {
    array = new Array<Params>();
    for(i in 0...PartyMgr.PARTY_MAX) {
      array.push(new Params());
    }
  }
  // セーブ
  public function save() {
    for(i in 0...PartyMgr.PARTY_MAX) {
      var p = Global.getParamFromIdx(i);
      array[i].copy(p);
    }
  }
  // ロード
  public function load(data:Dynamic) {
    for(idx in 0...data.array.length) {
      var param = data.array[idx];
      Global.getParamFromIdx(idx).copy(param);
    }
  }
}

// インベントリ
private class _Inventory {
  public var array:Array<ItemData>;

  public function new() {
  }
  // セーブ
  public function save() {
    array = Inventory.getItemList();
  }
  // ロード
  public function load(data:Dynamic) {
    var array = new Array<ItemData>();
    for(idx in 0...data.array.length) {
      var item = data.array[idx];
      var i = new ItemData(item.id);
      i.isEquip = item.isEquip;
      array.push(i);
    }
    Global.setItemList(array);
  }
}

// ノード情報
private class _Node {
  public var x:Float;
  public var y:Float;
  public var ev:String;
  public var eft:String;
  public var bStart:Bool;
  public var bFoot:Bool;
  public var bOpened:Bool;

  public function new() {
  }
}

// フィールド情報
private class _Field {
  public var array:Array<_Node>;

  public function new() {
  }

  // セーブ
  public function save() {
    this.array = new Array<_Node>();
    FieldNode.forEachAlive(function(node:FieldNode) {
      var n = new _Node();
      n.x = node.x;
      n.y = node.y;
      n.ev = FieldEventUtil.toString(node.evType);
      n.eft = FieldEffectUtil.toString(node.eftType);
      n.bStart = node.isStartFlag();
      n.bFoot = node.bFoot;
      n.bOpened = node.bOpened;
      this.array.push(n);
    });
  }
  // ロード
  public function load(data:Dynamic) {

    // テンポラリに保持する
    TmpFieldNode.create();

    for(idx in 0...data.array.length) {
      var node = data.array[idx];
      var x:Float      = node.x;
      var y:Float      = node.y;
      var ev:String    = node.ev;
      var eft:String   = node.eft;
      var bStart:Bool  = node.bStart;
      var bFoot:Bool   = node.bFoot;
      var bOpened:Bool = node.bOpened;
      TmpFieldNode.add(x, y, ev, eft, bStart, bFoot, bOpened);
    }
  }
}

private class _Foe {
  public var nodeID:Int;
  public var groupID:Int;
  public function new() {
  }
}

/**
 * F.O.E.
 **/
private class _FoeInfo {
  public var array:Array<_Foe>;

  public function new() {
  }
  // セーブ
  public function save() {
    array = new Array<_Foe>();
    FieldFoe.forEachAlive(function(foe:FieldFoe) {
      var e = new _Foe();
      e.nodeID  = foe.nodeID;
      e.groupID = foe.groupID;
      array.push(e);
    });
  }
  // ロード
  public function load(data:Dynamic) {

    // テンポラリに保持する
    TmpFieldFoe.create();

    for(idx in 0...data.array.length) {
      var foe = data.array[idx];
      var nodeID:Int = foe.nodeID;
      var groupID:Int = foe.groupID;
      TmpFieldFoe.add(nodeID, groupID);
    }
  }
}

// ショップ
private class _Shop {
  public var itemList:Array<ItemData>;
  public var equipList:Array<ItemData>;
  public var skillList:Array<SkillData>;
  public var food:Int;

  public function new() {
  }
  // セーブ
  public function save() {
    var shop = Global.getShopData();
    itemList = shop.itemList;
    equipList = shop.equipList;
    skillList = shop.skillList;
    food      = shop.food;
  }
  // ロード
  public function load(data:Dynamic) {
    var items = new Array<ItemData>();
    for(idx in 0...data.itemList.length) {
      var item = data.itemList[idx];
      var i = new ItemData(item.id);
      items.push(i);
    }
    var equips = new Array<ItemData>();
    for(idx in 0...data.equipList.length) {
      var equip = data.equipList[idx];
      var e = new ItemData(equip.id);
      equips.push(e);
    }
    var skills = new Array<SkillData>();
    for(idx in 0...data.skillList.length) {
      var skill = data.skillList[idx];
      var s = new SkillData(skill.id);
      skills.push(s);
    }
    var food = data.food;

    Global.getShopData().set(items, equips, skills, food);
  }
}

/**
 * セーブデータ
 **/
private class SaveData {
  public var global:_Global;
  public var party:_Party;
  public var inventory:_Inventory;
  public var field:_Field;
  public var foe:_FoeInfo;
  public var shop:_Shop;

  public function new() {
    global = new _Global();
    party = new _Party();
    inventory = new _Inventory();
    field = new _Field();
    foe = new _FoeInfo();
    shop = new _Shop();
  }

  // セーブ
  public function save() {
    global.save();
    party.save();
    inventory.save();
    field.save();
    foe.save();
    shop.save();
  }

  // ロード
  public function load(data:Dynamic) {
    global.load(data.global);
    party.load(data.player);
    inventory.load(data.inventory);
    field.load(data.field);
    foe.load(data.foe);
    shop.load(data.shop);
  }
}

/**
 * セーブ処理
 **/
class Save {
  public function new() {
  }

  /**
   * セーブする
   * @param bToText テキストへの保存を行うかどうか
   * @param bLog    ログ出力を行うかどうか
   **/
  public static function save(bToText:Bool, bLog:Bool):Void {

    var data = new SaveData();
    data.save();

    var str = Json.stringify(data);

    if(bToText) {
      // テキストへ保存する
#if neko
      sys.io.File.saveContent(Reg.PATH_SAVE, str);
      if(bLog) {
        trace("save ----------------------");
        trace(data);
      }
#end
    }
    else {
      // セーブ領域へ書き込み
      var saveutil = new FlxSave();
      saveutil.bind("SAVEDATA");
      saveutil.data.playdata = str;
      saveutil.flush();
    }
  }

  /**
   * ロードする
   * @param bFromText テキストから読み込みを行うかどうか
   * @param bLog      ログ出力を行うかどうか
   **/
  public static function load(bFromText:Bool, bLog:Bool):Void {
    var str = "";
#if neko
    str = sys.io.File.getContent(Reg.PATH_SAVE);
    if(bLog) {
      trace("load ----------------------");
      trace(str);
    }
#end

    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(bFromText) {
      // テキストファイルからロードする
      var data = Json.parse(str);
      var s = new SaveData();
      s.load(data);
    }
    else {
      var data = Json.parse(saveutil.data.playdata);
      var s = new SaveData();
      s.load(data);
    }
  }

  /**
   * セーブデータを消去する
   **/
  public static function erase():Void {
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    saveutil.erase();
  }

  public static function isContinue():Bool {
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(saveutil.data == null) {
      return false;
    }
    if(saveutil.data.playdata == null) {
      return false;
    }

    return true;
  }
}
