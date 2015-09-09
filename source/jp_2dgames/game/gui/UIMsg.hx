package jp_2dgames.game.gui;

import jp_2dgames.lib.CsvLoader;

/**
 * UIのメッセージ管理
 **/
class UIMsg {
  public static inline var ATTACK:Int  = 1; // 攻撃力
  public static inline var DEFENSE:Int = 2; // 守備力
  public static inline var YES:Int     = 3; // はい
  public static inline var NO:Int      = 4; // いいえ
  public static inline var ITEM_CHANGE = 5; // アイテムを捨てて手に入れる


  private static var _csv:CsvLoader = null;
  /**
   * CSV読み込み
   **/
  public static function load():Void {
    _csv = new CsvLoader(Reg.PATH_CSV_UI_MSG);
  }

  /**
   * メッセージテキスト取得
   **/
  public static function get(ID:Int):String {
    return _csv.getString(ID, "msg");
  }

  public static function get2(ID:Int, args:Array<Dynamic>):String {
    var msg = get(ID);
    if(args != null) {
      var idx:Int = 1;
      for(val in args) {
        msg = StringTools.replace(msg, '<val${idx}>', '${val}');
        idx++;
      }
    }

    return msg;
  }
}
