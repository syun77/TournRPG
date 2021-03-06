package jp_2dgames.game.state;

import jp_2dgames.game.field.FieldParticle;
import flixel.FlxG;
import flixel.FlxState;
import jp_2dgames.game.field.FieldFoe;
import jp_2dgames.game.field.FieldMgr;
import jp_2dgames.game.field.FieldNode;
import jp_2dgames.game.save.Save;

/**
 * フィールドシーン
 **/
class FieldState extends FlxState {

  // フィールド管理
  var _fieldMgr:FieldMgr;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // フィールド管理の生成
    _fieldMgr = new FieldMgr(this);
  }

  /**
   * 破棄
   */
  override public function destroy():Void {
    super.destroy();

    FieldParticle.terminate();
    FieldNode.destroyParent();
    FieldFoe.destroyParent();
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
          // 次のフロアに進む
          if(Global.nextFloor()) {
            // 次のフロアに進む
            FlxG.switchState(new FieldState());
          }
          else {
            // ゲームクリア
            FlxG.switchState(new ResultState());
          }
      }
    }

    // デバッグ機能の更新
    _updateDebug();
  }

  private function _updateDebug():Void {
    #if neko
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.S) {
      // セーブ
      Save.save(true, true);
    }
    if(FlxG.keys.justPressed.A) {
      // ロード
      Save.load(true, true);
      // ロードフラグを立てる
      Global.setLoadFlag(true);
      // シーンをやり直し
      FlxG.resetState();
    }
    if(FlxG.keys.justPressed.B) {
      // バトルテストシーン
      FlxG.switchState(new TestBattleState());
    }
    if(FlxG.keys.justPressed.M) {
      // お金を増やす
      var v = 100;
      if(FlxG.keys.pressed.SHIFT) {
        v *= 10;
      }
      Global.addMoney(v);
    }
    #end

  }
}

