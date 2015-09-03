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

  /**
   * 敵画像のパスを取得する
   **/
  public static function getEnemyImagePath(id:Int):String {
    var str = TextUtil.fillZero(id, 3);
    var path = 'assets/images/monster/${str}.png';

    return path;
  }
}