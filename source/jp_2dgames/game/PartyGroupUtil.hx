package jp_2dgames.game;

/**
 * グループ
 **/
enum PartyGroup {
  Player; // プレイヤー側
  Enemy;  // 敵側
}

/**
 * パーティグループのユーティリティ
 **/
class PartyGroupUtil {

  private static inline var PLAYER_OFS:Int = 1000;
  private static inline var ENEMY_OFS:Int  = 2000;

  /**
   * グループによってオフセットする番号を取得する
   **/
  public static function getOffsetID(group:PartyGroup) {
    switch(group) {
      case PartyGroup.Player:
        return PLAYER_OFS;
      case PartyGroup.Enemy:
        return ENEMY_OFS;
    }
  }

  /**
   * プレイヤー側かどうか
   **/
  public static function isPlayer(id:Int):Bool {
    if(PLAYER_OFS <= id && id < ENEMY_OFS) {
      return true;
    }
    return false;
  }

  /**
   * 敵側かどうか
   **/
  public static function isEnemy(id:Int):Bool {
    if(id >= ENEMY_OFS) {
      return true;
    }
    return false;
  }
}
