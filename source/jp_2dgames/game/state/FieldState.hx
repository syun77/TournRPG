package jp_2dgames.game.state;
import jp_2dgames.game.btl.logic.BtlLogicPlayer;
import jp_2dgames.game.btl.BtlMgr;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemConst;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.gui.Dialog;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxPoint;
import haxe.ds.ArraySort;
import jp_2dgames.game.field.FieldNode;
import flixel.FlxG;
import flixel.util.FlxRandom;
import flixel.FlxState;

/**
 * 線の描画
 **/
private class _Line extends FlxSpriteGroup {
  public function new() {
    super();
    for(i in 0...8) {
      var spr = new FlxSprite(0, 0).makeGraphic(2, 2, FlxColor.WHITE);
      this.add(spr);
    }
    visible = false;
  }
  public function drawLine(x1:Float, y1:Float, x2:Float, y2:Float):Void {

    var dx = (x2 - x1) / members.length;
    var dy = (y2 - y1) / members.length;

    var px = x1;
    var py = y1;
    for(spr in members) {
      spr.x = px;
      spr.y = py;
      px += dx;
      py += dy;
    }

    visible = true;
  }
}

/**
 * 状態
 **/
private enum State {
  Main;   // メイン
  Moving; // 移動中
  Battle; // バトル
  BattleEnd; // バトル終了
  Goal;   // ゴールにたどり着いた
}

/**
 * フィールドシーン
 **/
class FieldState extends FlxState {

  static inline var SIZE:Int = 32;

  // 状態
  var _state:State = State.Main;

  // 現在いるノード
  var _nowNode:FieldNode;

  // 経路描画
  var _line:_Line;

  // プレイヤートークン
  var _token:FlxSprite;

  // リザルトフラグ
  var _retBattle:Int = 0;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // ノード作成
    FieldNode.createParent(this);

    // ゴール
    FieldNode.add(FlxG.width/2, 32, FieldEvent.Goal);

    var imax:Int = Std.int(FlxG.width/SIZE);
    var jmax:Int = Std.int(FlxG.height/SIZE)-1;
    var rnd:Int = 10;
    for(j in 2...jmax) {
      for(i in 1...imax) {
        if(FlxRandom.intRanged(0, rnd) == 0) {
          var px = SIZE * i;
          var py = SIZE * j;
          var ev:FieldEvent = FieldEvent.None;
          var rnd2 = FlxRandom.intRanged(0, 10);
          if(rnd2 < 3) {
            // 何もなし
          }
          else if(rnd2 < 7) {
            // 敵
            ev = FieldEvent.Enemy;
          }
          else {
            // アイテム
            ev = FieldEvent.Item;
          }
          FieldNode.add(px, py, ev);
          rnd += 2;
        }
        else {
          rnd--;
        }
      }
    }

    // スタート地点
    _nowNode = FieldNode.add(FlxG.width/2, FlxG.height-32, FieldEvent.Start);

    // プレイヤー
    _token = new FlxSprite();
    _token.loadGraphic("assets/images/field/token.png", true);
    _token.animation.add("play", [0, 1], 2);
    _token.animation.play("play");
    this.add(_token);

    // 経路描画
    _line = new _Line();
    this.add(_line);

    // 到達可能な地点を検索
    _checkReachable();
  }

  /**
   * 破棄
   */
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 到達可能な地点を検索
   **/
  private function _checkReachable():Void {

    var nodeList = new Array<FieldNode>();
    FieldNode.forEachAlive(function(node:FieldNode) {
      nodeList.push(node);
    });

    ArraySort.sort(nodeList, function(a:FieldNode, b:FieldNode) {
      var y = Std.int(b.y - a.y) * 100;
      var ax = Math.abs(a.x - _nowNode.x);
      var bx = Math.abs(b.x - _nowNode.x);

      return y + Std.int(ax - bx);
    });

    var cnt:Int = 0;
    for(node in nodeList) {
      if(cnt < 5) {
        node.reachable = true;
        cnt++;

      }
      else {
        node.reachable = false;
      }
    }
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Main:
        _updateMain();
      case State.Moving:
        _updateMoving();
      case State.Goal:
        _updateGoal();
      case State.Battle:
      case State.BattleEnd:
        _updateBattleEnd();
    }

    #if neko
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
    #end
  }

  /**
   * 更新・メイン
   **/
  private function _updateMain():Void {

    // プレイヤーの位置を設定
    _token.x = _nowNode.x;
    _token.y = _nowNode.y - _token.height/2;

    var pt = FlxPoint.get(FlxG.mouse.x, FlxG.mouse.y);
    var selNode:FieldNode = null;
    FieldNode.forEachAlive(function(node:FieldNode) {
      node.scale.set(1, 1);
      if(node.reachable == false) {
        // 移動できないところは選べない
        return;
      }
      if(node.evType == FieldEvent.Start) {
        // スタート地点は選べない
        return;
      }

      if(node.overlapsPoint(pt)) {
        // 選択した
        selNode = node;
      }
    });

    if(selNode != null) {
      selNode.scale.set(1.5, 1.5);
      // 経路描画
      var x1 = _nowNode.xcenter;
      var y1 = _nowNode.ycenter;
      var x2 = selNode.xcenter;
      var y2 = selNode.ycenter;
      _line.drawLine(x1, y1, x2, y2);
    }
    else {
      _line.visible = false;
    }

    if(selNode != null) {
      if(FlxG.mouse.justPressed) {

        // 移動先を選択した
        FieldNode.forEachAlive(function(node:FieldNode) {
          if(node.reachable && node.evType != FieldEvent.Goal) {
            node.kill();
          }
        });
        selNode.revive();

        selNode.scale.set(1, 1);
        _line.visible = false;
        _state = State.Moving;
        FlxTween.tween(_token, {x:selNode.x, y:selNode.y-_token.height/2}, 1, {ease:FlxEase.sineOut, complete:function(tween:FlxTween) {
          // 移動完了
          _event(selNode.evType, selNode);
        }});
      }
    }
  }

  /**
   * イベント処理
   **/
  private function _event(event:FieldEvent, selNode:FieldNode):Void {

    switch(selNode.evType) {
      case FieldEvent.Goal:
        // ゴールにたどり着いた
        _state = State.Goal;
        Dialog.open(this, Dialog.OK, 'ゲームクリア！', null, function(btnID:Int) {
          FlxG.switchState(new ResultState());
        });

      case FieldEvent.Enemy:
        // バトル
        _state = State.Battle;
        // 戻り値初期化
        _retBattle = BtlLogicPlayer.BTL_END_NONE;
        Dialog.open(this, Dialog.OK, 'モンスターに遭遇した！', null, function(btnID:Int) {
          // バトル開始
          var nBtl = FlxRandom.intRanged(1, 4);
          Global.setStage(nBtl);
          _state = State.BattleEnd;
          selNode.setEventType(FieldEvent.Start);
          _nowNode = selNode;
          openSubState(new BattleState());
        });

      case FieldEvent.Item:
        // アイテム入手
        var item = new ItemData(ItemConst.ARMOR01);
        Inventory.push(item);
        var name = ItemUtil.getName(item);

        Dialog.open(this, Dialog.OK, '${name}を見つけた', null, function(btnID:Int) {
          // メイン処理に戻る
          selNode.setEventType(FieldEvent.Start);
          _nowNode = selNode;

          _checkReachable();
          _state = State.Main;
        });

      case FieldEvent.None:
        // メイン処理に戻る
        selNode.setEventType(FieldEvent.Start);
        _nowNode = selNode;

        _checkReachable();
        _state = State.Main;

      case FieldEvent.Start:
        throw '不正なイベントタイプ ${selNode.evType}';
    }
  }

  /**
   * 更新・移動中
   **/
  private function _updateMoving():Void {
  }

  /**
   * 更新・ゴール
   **/
  private function _updateGoal():Void {
  }

  /**
   * 更新・バトル
   **/
  private function _updateBattleEnd():Void {

    switch(_retBattle) {
      case BtlLogicPlayer.BTL_END_NONE:
        // バトル実行中

      case BtlLogicPlayer.BTL_END_LOSE:
        // ゲームオーバー
        FlxG.switchState(new ResultState());

      default:
        // メイン処理に戻る
        _checkReachable();
        _state = State.Main;
    }
  }

  /**
   * バトル結果フラグの設定
   **/
  public function setBattleResult(ret:Int):Void {
    _retBattle = ret;
  }
}

