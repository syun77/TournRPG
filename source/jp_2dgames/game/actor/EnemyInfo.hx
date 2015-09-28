package jp_2dgames.game.actor;

import jp_2dgames.lib.CsvLoader;

/**
 * 敵情報
 **/
class EnemyInfo {
  static var _csv:CsvLoader = null;

  /**
   * CSVの読み込み
   **/
  public static function load():Void {
    if(_csv == null) {
      _csv = new CsvLoader(Reg.PATH_CSV_ENEMY);
    }
  }

  public static function get(id:Int, key:String):Int {
    return _csv.getInt(id, key);
  }
  public static function getString(id:Int, key:String):String {
    return _csv.getString(id, key);
  }

  public static function setParam(param:Params, id:Int):Void {
    param.lv = 1;
    param.hp = get(id, "hp");
    param.hpmax = param.hp;
    param.str   = get(id, "str");
    param.vit   = get(id, "vit");
    param.agi   = get(id, "agi");
    param.xp    = get(id, "xp");
    param.money = get(id, "money");
  }
}
