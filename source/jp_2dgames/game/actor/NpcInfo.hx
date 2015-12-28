package jp_2dgames.game.actor;

import jp_2dgames.lib.CsvLoader;

/**
 * NPC情報
 **/
class NpcInfo {

  static var _csv:CsvLoader = null;

  /**
   * CSVの読み込み
   **/
  public static function load():Void {
    if(_csv == null) {
      _csv = new CsvLoader(Reg.PATH_CSV_PLAYER_NPC);
    }
  }

  public static function get(id:Int, key:String):Int {
    return _csv.searchItemInt("id", '${id}', key);
  }
  public static function getString(id:Int, key:String):String {
    return _csv.searchItem("id", '${id}', key);
  }

  public static function setParam(param:Params, id:Int):Void {
    param.id    = id;
    param.name  = getString(id, "name");
    param.lv    = 1;
    param.hp    = get(id, "hp");
    param.hpmax = param.hp;
    param.str = get(id, "str");
    param.vit = get(id, "vit");
    param.agi = get(id, "agi");
  }

  public function new() {
  }
}
