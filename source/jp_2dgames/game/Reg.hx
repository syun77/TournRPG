package jp_2dgames.game;

/**
 * staticフィールドとメソッドを持つグローバルクラス
 */
import jp_2dgames.lib.TextUtil;
class Reg {
  // フォントのパス
  public static inline var PATH_FONT = "assets/font/PixelMplus10-Regular.ttf";
  // スプライトフォント
  public static inline var PATH_SPR_FONT = "assets/font/font16x16.png";

  // フォントサイズ
  public static inline var FONT_SIZE = 20;
  public static inline var FONT_SIZE_S = 10;

  // メッセージウィンドウ
  public static inline var PATH_MSG = "assets/images/ui/message.png";
  // メッセージテキスト背景
  public static inline var PATH_MSG_TEXT = "assets/images/ui/messagetext.png";

  // CSV
  public static inline var PATH_CSV_MESSAGE = "assets/data/csv/message.csv";
  public static inline var PATH_CSV_PLAYER  = "assets/data/csv/player.csv";
  public static inline var PATH_CSV_ENEMY   = "assets/data/csv/enemy.csv";

  /**
   * 敵画像のパスを取得する
   **/
  public static function getEnemyImagePath(id:Int):String {
    var str = TextUtil.fillZero(id, 3);
    return 'assets/images/monster/${str}.png';
  }

  /**
   * 背景画像のパスを取得
   **/
  public static function getBackImagePath(id:Int):String {
    var str = TextUtil.fillZero(id, 3);
    return 'assets/images/bg/${str}.jpg';
  }
}