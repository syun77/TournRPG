package jp_2dgames.game.gui;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * バトルUI
 **/
class BtlUI extends FlxSpriteGroup {

  // ■定数
  static inline var PLAYER_X:Int = 4;
  static inline var PLAYER_Y:Int = 4;
  static inline var PLAYER_DY:Int = 12;

  // ■スタティック
  static var _instance:BtlUI = null;

  // 開く
  public static function open():Void {
    _instance = new BtlUI();
    FlxG.state.add(_instance);
  }

  // 閉じる
  public static function close():Void {
    FlxG.state.remove(_instance);
    _instance = null;
  }

  /**
   * プレイヤーのActorIDを設定する
   * @param idx     パーティ番号
   * @param actorID ActorID
   **/
  public static function setPlayerID(idx:Int, actorID:Int):Void {
    _instance._setPlayerID(idx, actorID);
  }

  // MISS
  public static function missPlayer(actorID):Void {
    _instance._missPlayer(actorID);
  }
  // ダメージ
  public static function damagePlayer(actorID:Int, val:Int):Void {
    _instance._damagePlayer(actorID, val);
  }

  // ■メンバ変数
  var _charaUIList:Array<BtlCharaUI>;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _charaUIList = new Array<BtlCharaUI>();

    for(i in 0...1) {
      var px = FlxG.width/3 * i;
      var ui = new BtlCharaUI(px, 4);
      _charaUIList.push(ui);
      this.add(ui);
    }
  }

  /**
   * プレイヤーのActorIDを設定する
   * @param idx     パーティ番号
   * @param actorID ActorID
   **/
  private function _setPlayerID(idx:Int, actorID:Int):Void {
    _charaUIList[idx].setActorID(actorID);
  }

  /**
   * キャラUIを取得する
   * @return 取得できなかったら null
   **/
  private function _getCharaUI(actorID:Int):BtlCharaUI {

    for(ui in _charaUIList) {
      if(actorID == ui.actorID) {
        // 見つかった
        return ui;
      }
    }

    // 見つからなかった
    return null;
  }

  /**
   * MISS演出開始
   **/
  private function _missPlayer(actorID:Int):Void {
    var ui = _getCharaUI(actorID);
    if(ui != null) {
      ui.miss();
    }
  }

  /**
   * ダメージ演出開始
   **/
  private function _damagePlayer(actorID:Int, val:Int):Void {

    // ダメージ演出
    {
      var ui = _getCharaUI(actorID);
      if(ui != null) {
        ui.damage(val);
      }
    }

    // 全部揺らす
    for(ui in _charaUIList) {
      ui.shake();
    }
  }

  override public function update():Void {
    super.update();
  }
}
