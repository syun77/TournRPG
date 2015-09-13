package jp_2dgames.game.gui;

import flixel.FlxG;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.btl.types.BtlRange;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.Actor;
import flixel.group.FlxSpriteGroup;

/**
 * 対象選択UI
 **/
class BtlTargetUI extends FlxSpriteGroup {

  // ■定数
  public static inline var CMD_CANCEL:Int = -1;

  // ■スタティック
  private static var _instance:BtlTargetUI = null;

  // 開く
  public static function open(cbFunc:Int->Void, group:BtlGroup, range:BtlRange) {
    if(_instance == null) {
      _instance = new BtlTargetUI(cbFunc, group, range);
      FlxG.state.add(_instance);
    }
  }

  /**
   * コンストラクタ
   * @param cbFunc 選択実行時のコールバック関数
   * @param group  効果対象
   * @param range  効果範囲
   **/
  public function new(cbFunc:Int->Void, group:BtlGroup, range:BtlRange) {
    super();

    var btnList = new Array<MyButton>();
    // 対象Actorを決める
    ActorMgr.forEachAliveGroup(group, function(actor:Actor) {
      var px = actor.xcenter - MyButton.WIDTH/2;
      var py = actor.bottom;
      var btn = new MyButton(px, py, actor.name, function() {
        _click(cbFunc, actor.ID);
      });
      btnList.push(btn);
    });

    var cnt = btnList.length;
    var idx = 0;
    for(btn in btnList) {
      btn.scrollFactor.set(0, 0);
      this.add(btn);

      idx++;
    }
  }

  /**
   * ボタンをクリックした
   **/
  private function _click(cbFunc:Int->Void, targetID:Int):Void {
    cbFunc(targetID);
    _close();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
  }

  /**
   * UIを閉じる
   **/
  private function _close():Void {
    kill();
    FlxG.state.remove(this);
    _instance = null;
  }
}
