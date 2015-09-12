package jp_2dgames.game.btl;

/**
 * バトルグループ
 **/
enum BtlGroup {
  Player; // プレイヤー側
  Enemy;  // 敵側
  Both;   // 両方
}

/**
 * パーティグループのユーティリティ
 **/
class BtlGroupUtil {

  private static inline var PLAYER_OFS:Int = 1000;
  private static inline var ENEMY_OFS:Int  = 2000;

  /**
   * グループによってオフセットする番号を取得する
   **/
  public static function getOffsetID(group:BtlGroup) {
    switch(group) {
      case BtlGroup.Player:
        return PLAYER_OFS;
      case BtlGroup.Enemy:
        return ENEMY_OFS;
      case BtlGroup.Both:
        return 0;
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

  /**
   * IDに対応するグループを取得する
   **/
  public static function get(id:Int):BtlGroup {
    if(isPlayer(id)) {
      return BtlGroup.Player;
    }
    if(isEnemy(id)) {
      return BtlGroup.Enemy;
    }

    return BtlGroup.Both;
  }

  /**
   * 指定のIDとグループと一致しているかどうか
   **/
  public static function isSameFromID(id:Int, group:BtlGroup):Bool {
    switch(group) {
      case BtlGroup.Player:
        return isPlayer(id);
      case BtlGroup.Enemy:
        return isEnemy(id);
      case BtlGroup.Both:
        return true;
    }
  }

  /**
   * 同一のグループかどうか
   **/
  public static function isSame(gr1:BtlGroup, gr2:BtlGroup):Bool {
    if(gr1 == BtlGroup.Both || gr2 == BtlGroup.Both) {
      return true;
    }

    return gr1 == gr2;
  }

  /**
   * 対抗するグループを取得する
   **/
  public static function getAgaint(group:BtlGroup):BtlGroup {
    switch(group) {
      case BtlGroup.Player:
        return BtlGroup.Enemy;
      case BtlGroup.Enemy:
        return BtlGroup.Player;
      case BtlGroup.Both:
        return BtlGroup.Both;
    }
  }
}
