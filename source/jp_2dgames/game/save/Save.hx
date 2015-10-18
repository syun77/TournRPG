package jp_2dgames.game.save;

import jp_2dgames.game.field.TmpFieldNode;
import jp_2dgames.game.field.FieldNodeUtil;
import jp_2dgames.game.field.FieldNode;
import jp_2dgames.game.field.FieldEvent;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.ActorMgr;
import flixel.util.FlxSave;
import jp_2dgames.game.Reg;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.actor.Params;
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
    enemyGroup = Global.getEnemyGroup();
    money      = Global.getMoney();
    floor      = Global.getFloor();
  }
  // ロード
  public function load(data:Dynamic) {
    Global.setEnemyGroup(data.enemyGroup);
    Global.setMoney(data.money);
    Global.setFloor(data.floor);
  }
}

// プレイヤー
private class _Player {
  public var params:Params;
  public function new() {
  }
  // セーブ
  public function save() {
    params = Global.getPlayerParam();
  }
  // ロード
  public function load(data:Dynamic) {
    var prms = new Params();
    prms.copy(data.params);
    Global.setPlayerParam(prms);
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
  public var bStart:Bool;
  public var bFoot:Bool;

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
      n.bStart = node.isStartFlag();
      n.bFoot = node.bFoot;
      this.array.push(n);
    });
  }
  // ロード
  public function load(data:Dynamic) {

    // テンポラリに保持する
    TmpFieldNode.create();

    for(idx in 0...data.array.length) {
      var node = data.array[idx];
      var x:Float     = node.x;
      var y:Float     = node.y;
      var ev:String   = node.ev;
      var bStart:Bool = node.bStart;
      var bFoot:Bool  = node.bFoot;
      TmpFieldNode.add(x, y, ev, bStart, bFoot);
    }
  }
}

/**
 * セーブデータ
 **/
private class SaveData {
  public var global:_Global;
  public var player:_Player;
  public var inventory:_Inventory;
  public var field:_Field;

  public function new() {
    global = new _Global();
    player = new _Player();
    inventory = new _Inventory();
    field = new _Field();
  }

  // セーブ
  public function save() {
    global.save();
    player.save();
    inventory.save();
    field.save();
  }

  // ロード
  public function load(data:Dynamic) {
    global.load(data.global);
    player.load(data.player);
    inventory.load(data.inventory);
    field.load(data.field);
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
