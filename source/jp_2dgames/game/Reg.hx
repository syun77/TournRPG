package jp_2dgames.game;

import flixel.util.FlxRandom;
import jp_2dgames.lib.TextUtil;

/**
 * リソースのパスや共通の定数
 */
class Reg {

  // ■フォント
  // フォントのパス
  public static inline var PATH_FONT = "assets/font/PixelMplus10-Regular.ttf";
  // スプライトフォント
  public static inline var PATH_SPR_FONT = "assets/font/font16x16.png";

  // フォントサイズ
  public static inline var FONT_SIZE = 20;
  public static inline var FONT_SIZE_S = 10;

  // ■ボタン
  public static inline var BTN_OFS_X:Int = 4;
  public static inline var BTN_OFS_DX:Int = 2;
  public static inline var BTN_OFS_DY:Int = 2;

  // 敵の出現位置
  public static inline var ENEMY_OFS_Y:Int = -48;

  // メッセージウェイト
  public static inline var TIMER_WAIT:Int = 30; // 0.5秒
  public static inline var TIMER_WAIT_HIT:Int = 15; // 0.25秒
  public static inline var TIMER_WAIT_SEQUENCE:Int = 15; // 0.25秒

  // ■画像データ
  // メッセージウィンドウ
  public static inline var PATH_MSG = "assets/images/ui/message.png";
  // メッセージテキスト背景
  public static inline var PATH_MSG_TEXT = "assets/images/ui/messagetext.png";
  // バッドステータスアイコン
  public static inline var PATH_BADSTATUS = "assets/images/ui/badstatus.png";
  // フィールド画像
  public static inline var PATH_FIELD_MAP = "assets/images/field/field.png";
  // フィールドのプレイヤーアイコン
  public static inline var PATH_FIELD_PLAYER_ICON = "assets/images/field/token.png";
  // フィールドのF.O.E.アイコン
  public static inline var PATH_FIELD_FOE_ICON = "assets/images/field/foe.png";
  // フィールドのノード
  public static inline var PATH_FIELD_NODE = "assets/images/field/node.png";
  // フィールドでの食糧アイコン
  public static inline var PATH_FIELD_FOOD = "assets/images/field/food.png";
  // フィールドでの所持金アイコン
  public static inline var PATH_FIELD_MONEY = "assets/images/field/money.png";
  // メニューの背景
  public static inline var PATH_MENU_BG = "assets/images/ui/menu_bg.png";
  // ショップ
  // ・消耗品
  public static inline var PATH_SHOP_ITEM = "assets/images/ui/shop/potion.png";
  // ・装備品
  public static inline var PATH_SHOP_EQUIP = "assets/images/ui/shop/weapon.png";
  // ・スキル
  public static inline var PATH_SHOP_SKILL = "assets/images/ui/shop/skill.png";
  // ・食糧
  public static inline var PATH_SHOP_FOOD = "assets/images/ui/shop/food.png";
  // ・カーソル
  public static inline var PATH_SHOP_CURSOR = "assets/images/ui/shop/cursor.png";

  // CSV
  public static inline var PATH_CSV_MESSAGE         = "assets/data/csv/message.csv";
  public static inline var PATH_CSV_PLAYER          = "assets/data/csv/player.csv";
  public static inline var PATH_CSV_PLAYER_INIT     = "assets/data/csv/player_init.csv";
  public static inline var PATH_CSV_PLAYER_NPC      = "assets/data/csv/player_npc.csv";
  public static inline var PATH_CSV_ENEMY           = "assets/data/csv/enemy.csv";
  public static inline var PATH_CSV_ENEMY_GROUP     = "assets/data/csv/enemy_group.csv";
  public static inline var PATH_CSV_ITEM_CONSUMABLE = "assets/data/csv/item_consumable.csv";
  public static inline var PATH_CSV_ITEM_EQUIPMENT  = "assets/data/csv/item_equipment.csv";
  public static inline var PATH_CSV_UI_MSG          = "assets/data/csv/ui.csv";
  public static inline var PATH_CSV_SKILL_NORMAL    = "assets/data/csv/skill.csv";
  public static inline var PATH_CSV_SKILL_AUTO      = "assets/data/csv/skill_auto.csv";
  public static inline var PATH_CSV_FIELD_ITEM      = "assets/data/csv/field_item.csv";
  public static inline var PATH_CSV_FIELD_SKILL     = "assets/data/csv/field_skill.csv";

  // セーブデータ保存先
  public static inline var PATH_SAVE = "/Users/syun/Desktop/TournRPG/save.txt";

  // 食糧の価格
  public static inline var COST_FOOD:Int = 10;
  // 空腹ダメージ
  public static inline var FOOD_DAMAGE:Float = 0.2;

  /**
   * 敵画像のパスを取得する
   **/
  public static function getEnemyImagePath(name:String):String {
    return 'assets/images/monster/${name}';
  }

  /**
   * 敵のスクリプトのパスを取得する
   **/
  public static function getEnemyScriptPath(name:String):String {
    return 'assets/data/ai/${name}.csv';
  }

  /**
   * NPCのスクリプトのパスを取得する
   **/
  public static function getNpcScriptPath(id:Int):String {
    var name = TextUtil.fillZero(id, 3);
    return 'assets/data/ai/npc${name}.csv';
  }

  /**
   * 背景画像のパスを取得
   **/
  public static function getBackImagePath(id:Int):String {
    var str = TextUtil.fillZero(id, 3);
    return 'assets/images/bg/${str}.jpg';
  }

  /**
   * 連続攻撃時にランダムで移動させる座標値を取得する
   **/
  public static function getContinuousAttackRandom():Int {
    return FlxRandom.intRanged(-32, 32);
  }

  // エフェクト
  public static inline var PATH_EFFECT = "assets/images/effect/effect.png";
}