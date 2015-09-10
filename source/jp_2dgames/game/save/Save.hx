package jp_2dgames.game.save;

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
  public var stage:Int; // ステージ番号
  public var money:Int; // 所持金
  public function new() {
  }
  // セーブ
  public function save() {
    stage = Global.getStage();
    money = Global.getMoney();
  }
  // ロード
  public function load(data:Dynamic) {
    Global.setStage(data.stage);
    Global.setMoney(data.money);
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
    ActorMgr.forEachAliveGroup(BtlGroup.Player, function(actor:Actor) {
      actor.param.copy(prms);
    });
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

/**
 * セーブデータ
 **/
private class SaveData {
  public var global:_Global;
  public var player:_Player;
  public var inventory:_Inventory;

  public function new() {
    global = new _Global();
    player = new _Player();
    inventory = new _Inventory();
  }

  // セーブ
  public function save() {
    global.save();
    player.save();
    inventory.save();
  }

  // ロード
  public function load(data:Dynamic) {
    global.load(data.global);
    player.load(data.player);
    inventory.load(data.inventory);
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
