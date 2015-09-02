package jp_2dgames.game;

/**
 * グループ
 **/
import openfl._internal.aglsl.assembler.Part;
enum PartyGroup {
  Player; // プレイヤー側
  Enemy;  // 敵側
  Both;   // 両方
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
      case PartyGroup.Both:
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
  public static function get(id:Int):PartyGroup {
    if(isPlayer(id)) {
      return PartyGroup.Player;
    }
    if(isEnemy(id)) {
      return PartyGroup.Enemy;
    }

    return PartyGroup.Both;
  }

  /**
   * 指定のグループと一致しているかどうか
   **/
  public static function isSame(id:Int, group:PartyGroup):Bool {
    switch(group) {
      case PartyGroup.Player:
        return isPlayer(id);
      case PartyGroup.Enemy:
        return isEnemy(id);
      case PartyGroup.Both:
        return true;
    }
  }

  /**
   * 対抗するグループを取得する
   **/
  public static function getAgaint(group:PartyGroup):PartyGroup {
    switch(group) {
      case PartyGroup.Player:
        return PartyGroup.Enemy;
      case PartyGroup.Enemy:
        return PartyGroup.Player;
      case PartyGroup.Both:
        return PartyGroup.Both;
    }
  }
}
