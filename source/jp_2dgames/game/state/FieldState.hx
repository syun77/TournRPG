package jp_2dgames.game.state;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import jp_2dgames.game.field.FieldMgr;
import jp_2dgames.game.field.FieldNode;
import jp_2dgames.lib.RectLine;

/**
 * フィールドシーン
 **/
class FieldState extends FlxState {

  // 現在いるノード
  var _nowNode:FieldNode;

  // 経路描画
  var _line:RectLine;

  // プレイヤートークン
  var _token:FlxSprite;

  // リザルトフラグ
  var _retBattle:Int = 0;
  public var retBattle(get, never):Int;
  private function get_retBattle() {
    return _retBattle;
  }

  // フィールド管理
  var _fieldMgr:FieldMgr;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    var bg = new FlxSprite().loadGraphic(Reg.PATH_FIELD_MAP);
    bg.color = FlxColor.SILVER;
    this.add(bg);

    // ノード管理作成
    FieldNode.createParent(this);

    // フィールド管理の生成
    _fieldMgr = new FieldMgr(this);

  }

  /**
   * 破棄
   */
  override public function destroy():Void {
    FieldNode.destroyParent(this);

    super.destroy();
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();

    _fieldMgr.proc();
    if(_fieldMgr.isEnd()) {
      // 終了
      switch(_fieldMgr.resultCode) {
        case FieldMgr.RET_GAMEOVER:
          // ゲームオーバー
          FlxG.switchState(new ResultState());

        case FieldMgr.RET_NEXTSTAGE:
          // TODO: 次のステージに進む
          FlxG.switchState(new ResultState());
      }
    }

    // デバッグ機能の更新
    _updateDebug();
  }

  /**
   * バトル結果フラグの設定
   **/
  public function setBattleResult(ret:Int):Void {
    _retBattle = ret;
  }

  private function _updateDebug():Void {
    #if neko
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
    #end

  }
}

