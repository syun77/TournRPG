package jp_2dgames.game.gui;

import jp_2dgames.game.gui.message.UIMsg;
import flixel.util.FlxDestroyUtil;
import flixel.FlxState;
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

  // 座標
  // キャンセルボタンのオフセット
  private static inline var BTN_CANCEL_OFS_Y = 64;

  // ■スタティック
  private static var _instance:BtlTargetUI = null;

  private static var _state:FlxState = null;

  // 開く
  public static function open(state:FlxState, cbFunc:Int->Void, group:BtlGroup, range:BtlRange) {
    if(_instance == null) {
      _instance = new BtlTargetUI(cbFunc, group, range);
      state.add(_instance);
      _state = state;
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

    var btnList = new Array<MyButton2>();

    // 対象Actorを決めるボタン
    switch(range) {
      case BtlRange.Self:
        // 自分自身
        throw '未実装の効果範囲 ${range}';

      case BtlRange.One:
        // 単体
        ActorMgr.forEachAliveGroup(group, function(actor:Actor) {
          var btn = _addButtonTargetOne(cbFunc, group, actor);
          btnList.push(btn);
        });

      case BtlRange.Group:
        // グループ

        // 最も下の座標にいるactorを取得する
        var py:Float = 0;
        var actor = null;
        ActorMgr.forEachAliveGroup(group, function(act:Actor) {
          if(act.bottom > py) {
            py = act.bottom;
            actor = act;
          }
        });

        var px = FlxG.width/2 - MyButton2.WIDTH/2;
        var name = UIMsg.get(UIMsg.CMD_ENEMY_ALL);
        var btn = new MyButton2(px, py, name, function() {
          _click(cbFunc, actor.ID);
        });
        btnList.push(btn);

      case BtlRange.All:
        // 全体
        throw '未実装の効果範囲 ${range}';
    }

    // キャンセルボタン
    {
      var px = FlxG.width/2 - MyButton2.WIDTH/2;
      var py = FlxG.height - BTN_CANCEL_OFS_Y;
      var label = UIMsg.get(UIMsg.CANCEL);
      var btn = new MyButton2(px, py, label, function() {
        // キャンセル
        _click(cbFunc, CMD_CANCEL);
      });
      btnList.push(btn);
    }

    var cnt = btnList.length;
    for(btn in btnList) {
      btn.scrollFactor.set(0, 0);
      this.add(btn);
    }
  }

  /**
   * ボタン作成（単体）
   **/
  private function _addButtonTargetOne(cbFunc:Int->Void, group:BtlGroup, actor:Actor):MyButton2 {

    var px = actor.xcenter - MyButton2.WIDTH/2;
    var py = actor.bottom;
    if(group == BtlGroup.Player) {
      px = actor.x_ui;
      py = actor.y_ui;
      py += 320;
    }

    var btn = new MyButton2(px, py, actor.name, function() {
      _click(cbFunc, actor.ID);
    });

    return btn;
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
    _state.remove(this);
    _instance = FlxDestroyUtil.destroy(_instance);
    _state = null;
  }
}
