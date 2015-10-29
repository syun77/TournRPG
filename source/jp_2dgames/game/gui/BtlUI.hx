package jp_2dgames.game.gui;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * バトルUI
 **/
class BtlUI extends FlxSpriteGroup {

  // ■定数
  public static inline var CHARA_Y:Int = 16;

  // ■スタティック
  static var _instance:BtlUI = null;

  // 開く
  public static function open(state:FlxState):Void {
    _instance = new BtlUI();
    state.add(_instance);
  }

  // 閉じる
  public static function close(state:FlxState):Void {
    state.remove(_instance);
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
  public static function getCenterX(actorID):Float {
    return _instance._getCenterX(actorID);
  }
  public static function getCenterY(actorID):Float {
    return _instance._getCenterY(actorID);
  }
  // 座標取得
  public static function getPlayerX(actorID:Int):Float {
    return _instance._getPlayerX(actorID);
  }
  public static function getPlayerY(actorID:Int):Float {
    return _instance._getPlayerY(actorID);
  }
  // 揺らす
  public static function shake():Void {
    _instance._shake();
  }
  // ダメージ
  public static function damage():Void {
    _instance._damage();
  }
  // アクティブ
  public static function setActivePlayer(actorID:Int, b:Bool):Void {
    _instance._setActivePlayer(actorID, b);
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
      var ui = new BtlCharaUI(px, CHARA_Y);
      _charaUIList.push(ui);
      ui.y = -48;
      FlxTween.tween(ui, {y:CHARA_Y}, 0.5, {ease:FlxEase.expoOut});
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

  private function _getCenterX(actorID:Int):Float {
    var ui = _getCharaUI(actorID);
    if(ui != null) {
      return ui.xcenter;
    }
    return 0;
  }
  private function _getCenterY(actorID:Int):Float {
    var ui = _getCharaUI(actorID);
    if(ui != null) {
      return ui.ycenter;
    }
    return 0;
  }

  /**
   * プレイヤーUIの中心座標(X)を取得する
   **/
  private function _getPlayerX(actorID:Int):Float {
    var ui = _getCharaUI(actorID);
    if(ui != null) {
      return ui.xcenter;
    }

    return FlxG.width/2;
  }

  /**
   * プレイヤーUIの中心座標(Y)を取得する
   **/
  private function _getPlayerY(actorID:Int):Float {
    var ui = _getCharaUI(actorID);
    if(ui != null) {
      return ui.ycenter;
    }

    return FlxG.height/2;
  }

  /**
   * 揺らす
   **/
  private function _shake():Void {
    for(ui in _charaUIList) {
      ui.shake();
    }
  }

  /**
   * ダメージ
   **/
  private function _damage():Void {
    for(ui in _charaUIList) {
      ui.damage();
    }
  }

  /**
   * アクティブ状態を設定する
   **/
  private function _setActivePlayer(actorID:Int, b:Bool):Void {
    var ui = _getCharaUI(actorID);
    if(ui != null) {
      ui.setActive(b);
    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
  }
}
