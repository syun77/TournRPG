package jp_2dgames.game.actor;

import jp_2dgames.lib.CsvLoader;

/**
 * プレイヤー情報
 **/
class PlayerInfo {
  static var _csv:CsvLoader = null;

  /**
   * CSVの読み込み
   **/
  public static function load():Void {
    if(_csv == null) {
      _csv = new CsvLoader(Reg.PATH_CSV_PLAYER);
    }
  }

  public static function get(id:Int, key:String):Int {
    return _csv.getInt(id, key);
  }
  public static function getString(id:Int, key:String):String {
    return _csv.getString(id, key);
  }

  /**
   * パラメータ設定
   * @parma param 設定先パラメータ
   * @param lv    レベル
   **/
  public static function setParam(param:Params, lv:Int):Void {
    param.id    = 0;
    param.lv    = lv;
    param.hp    = get(lv, "hp");
    param.hpmax = param.hp;
    param.str   = get(lv, "str");
    param.vit   = get(lv, "vit");
    param.agi   = get(lv, "agi");
  }
}
