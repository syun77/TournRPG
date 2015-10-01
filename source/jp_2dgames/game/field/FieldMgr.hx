package jp_2dgames.game.field;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxPoint;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxRandom;
import jp_2dgames.game.state.FieldState;
import jp_2dgames.game.state.BattleState;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.state.ResultState;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.skill.SkillConst;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.gui.Dialog;
import jp_2dgames.game.btl.logic.BtlLogicPlayer;
import jp_2dgames.game.item.ItemConst;
import jp_2dgames.lib.RectLine;
import jp_2dgames.lib.Snd;

/**
 * 状態
 **/
private enum State {
  Main;   // メイン
  Moving; // 移動中
  Battle; // バトル
  BattleEnd; // バトル終了
  Goal;   // ゴールにたどり着いた

  End;    // 終了
}

/**
 * フィールド管理
 **/
class FieldMgr {

  // 戻り値
  public static inline var RET_NONE:Int      = 0;
  public static inline var RET_NEXTSTAGE:Int = 1;
  public static inline var RET_GAMEOVER:Int  = 2;

  // 状態
  var _state:State = State.Main;

  // 親
  var _flxState:FieldState;

  // 現在いるノード
  var _nowNode:FieldNode;

  // 経路描画
  var _line:RectLine;

  // プレイヤートークン
  var _token:FlxSprite;

  // 戻り値
  var _resultCode:Int = RET_NONE;
  public var resultCode(get, never):Int;
  private function get_resultCode() {
    return _resultCode;
  }

  /**
   * コンストラクタ
   **/
  public function new(flxState:FieldState) {
    _flxState = flxState;

    // マップの作成
    _nowNode = FieldNodeUtil.create();

    // プレイヤー
    _token = new FlxSprite();
    _token.loadGraphic(Reg.PATH_FIELD_PLAYER_ICON, true);
    _token.animation.add("play", [0, 1], 2);
    _token.animation.play("play");
    _flxState.add(_token);

    // 経路描画
    _line = new RectLine(8);
    flxState.add(_line);

  }

  /**
   * 更新
   **/
  public function proc():Void {

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

      case State.End:
        // おしまい
    }
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
        Dialog.open(_flxState, Dialog.OK, 'ゲームクリア！', null, function(btnID:Int) {
          _state = State.End;
          _resultCode = RET_NEXTSTAGE;
        });

      case FieldEvent.Enemy:
        // バトル
        _state = State.Battle;
        Snd.playSe("roar");
        // 戻り値初期化
        _flxState.setBattleResult(BtlLogicPlayer.BTL_END_NONE);
        Dialog.open(_flxState, Dialog.OK, 'モンスターに遭遇した！', null, function(btnID:Int) {
          // バトル開始
          var nBtl = FlxRandom.intRanged(1, 4);
          Global.setStage(nBtl);
          _state = State.BattleEnd;
          selNode.setEventType(FieldEvent.Start);
          _nowNode = selNode;
          _flxState.openSubState(new BattleState());
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

        Dialog.open(_flxState, Dialog.OK, msg, null, function(btnID:Int) {
          // メイン処理に戻る
          selNode.setEventType(FieldEvent.Start);
          _nowNode = selNode;

          // 到達可能な地点を検索
          FieldNodeUtil.addReachableNode(_nowNode);
          _nowNode.openNodes();

          _state = State.Main;
        });

      case FieldEvent.None:
        // お金を拾う
        var money = FlxRandom.intRanged(1, 5);
        Global.addMoney(money);
        // SE再生
        Snd.playSe("coin");

        Dialog.open(_flxState, Dialog.OK, '${money}G拾った', null, function(btnID:Int) {

          // メイン処理に戻る
          selNode.setEventType(FieldEvent.Start);
          _nowNode = selNode;

          // 到達可能な地点を検索
          FieldNodeUtil.addReachableNode(_nowNode);
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

    switch(_flxState.retBattle) {
      case BtlLogicPlayer.BTL_END_NONE:
        // バトル実行中

      case BtlLogicPlayer.BTL_END_LOSE:
        // ゲームオーバー
        _state = State.End;
        _resultCode = RET_GAMEOVER;

      default:
        // メイン処理に戻る
        // 到達可能な地点を検索
        FieldNodeUtil.addReachableNode(_nowNode);
        _nowNode.openNodes();

        _state = State.Main;
    }
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }
}
