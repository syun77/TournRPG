package jp_2dgames.game;

import jp_2dgames.game.actor.Params;
import jp_2dgames.game.actor.PlayerInfo;

/**
 * グローバル情報
 **/
class Global {
  static var _playerParam:Params;

  public static function init():Void {

    // プレイヤー情報の初期化
    _initPlayer();
  }

  // プレイヤー情報の初期化
  private static function _initPlayer():Void {
    _playerParam = new Params();
    PlayerInfo.setParam(_playerParam, 1);
  }

  // プレイヤー情報の取得
  public static function getPlayerParam():Params {
    return _playerParam;
  }
  public static function setPlayerHp(hp:Int):Void {
    _playerParam.hp = hp;
  }
}
