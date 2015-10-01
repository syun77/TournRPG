package jp_2dgames.game.state;

import flixel.util.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import haxe.ds.ArraySort;
import jp_2dgames.lib.RectLine;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.field.FieldEvent;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.skill.SkillConst;
import jp_2dgames.game.btl.logic.BtlLogicPlayer;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemConst;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.gui.Dialog;
import jp_2dgames.game.field.FieldNode;

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

  // 状態
  var _state:State = State.Main;

  // 現在いるノード
  var _nowNode:FieldNode;

  // 経路描画
  var _line:RectLine;

  // プレイヤートークン
  var _token:FlxSprite;

  // リザルトフラグ
  var _retBattle:Int = 0;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    var bg = new FlxSprite().loadGraphic(Reg.PATH_FIELD_MAP);
    this.add(bg);

    // ノード作成
    FieldNode.createParent(this);

    // ゴール
    var size = FieldNode.SIZE;
    FieldNode.add(size*4, size, FieldEvent.Goal);

    var imax:Int = Std.int(FlxG.width/size);
    var jmax:Int = Std.int(FlxG.height/size)-1;
    var rnd:Int = 10;
    for(j in 2...jmax) {
      for(i in 1...imax) {
        if(FlxRandom.intRanged(0, rnd) == 0) {
          var px = size * i;
          var py = size * j;
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
    // 到達可能な地点を検索
    _checkReachableNode(_nowNode);
    _nowNode.openNodes();

    // プレイヤー
    _token = new FlxSprite();
    _token.loadGraphic(Reg.PATH_FIELD_PLAYER_ICON, true);
    _token.animation.add("play", [0, 1], 2);
    _token.animation.play("play");
    this.add(_token);

    // 経路描画
    _line = new RectLine(8);
    this.add(_line);

  }

  private function _checkReachableNode(node:FieldNode):Void {
    var cnt:Int = 0;
    FieldNode.forEachAlive(function(n:FieldNode) {
      if(node.ID == n.ID) {
        // 同一ノード
        return;
      }
      var distance = FlxMath.distanceBetween(node, n);
      if(distance < 64) {
        if(node.addReachableNodes(n)) {
          // 追加できた
          cnt++;
        }
      }
    });

    if(cnt > 1) {
      // 接続ノードが2つ以上存在したのでおしまい
      return;
    }

    var nodes = FieldNode.getNearestSortedList(node);
    for(n in nodes) {
      node.addReachableNodes(n);
      cnt++;
      if(cnt >= 2) {
        break;
      }
    }
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
      // 選択しているノードがある
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
        Snd.playSe("roar");
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

        var msg:String = "";

        // スキル入手
        var getSkill = function() {
          var skills = Global.getSkillSlot();
          if(skills.length == 0) {
            // スキルを持っていない
            if(FlxRandom.chanceRoll(30)) {
              var skillID = SkillConst.SKILL001 + FlxRandom.intRanged(0, 1);
              var skill = new SkillData(skillID);
              skills.push(skill);
              var name = SkillUtil.getName(skillID);
              msg = 'スキル「${name}」を覚えた';
              return true;
            }
          }
          // スキルを取得しなかった
          return false;
        };

        if(getSkill() == false) {

          // アイテム入手
          var tbl = [
            ItemConst.POTION01,
            ItemConst.POTION01,
            ItemConst.POTION01,
            ItemConst.POTION02,
            ItemConst.WEAPON01,
            ItemConst.WEAPON02,
            ItemConst.WEAPON03,
            ItemConst.ARMOR01,
            ItemConst.ARMOR02,
            ItemConst.ARMOR03
          ];
          FlxArrayUtil.shuffle(tbl, 5);
          var item = new ItemData(tbl[0]);
          Inventory.push(item);
          var name = ItemUtil.getName(item);
          msg = '${name}を見つけた';
        }

        Snd.playSe("powerup");

        Dialog.open(this, Dialog.OK, msg, null, function(btnID:Int) {
          // メイン処理に戻る
          selNode.setEventType(FieldEvent.Start);
          _nowNode = selNode;

          // 到達可能な地点を検索
          _checkReachableNode(_nowNode);
          _nowNode.openNodes();

          _state = State.Main;
        });

      case FieldEvent.None:
        // お金を拾う
        var money = FlxRandom.intRanged(1, 5);
        Global.addMoney(money);
        // SE再生
        Snd.playSe("coin");

        Dialog.open(this, Dialog.OK, '${money}G拾った', null, function(btnID:Int) {

          // メイン処理に戻る
          selNode.setEventType(FieldEvent.Start);
          _nowNode = selNode;

          // 到達可能な地点を検索
          _checkReachableNode(_nowNode);
          _nowNode.openNodes();

          _state = State.Main;
        });

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
        // 到達可能な地点を検索
        _checkReachableNode(_nowNode);
        _nowNode.openNodes();

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

