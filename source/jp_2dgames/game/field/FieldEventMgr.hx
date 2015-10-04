package jp_2dgames.game.field;

import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.util.Generator;
import flixel.util.FlxRandom;
import jp_2dgames.game.state.BattleState;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.skill.SkillConst;
import jp_2dgames.game.btl.logic.BtlLogicPlayer;
import jp_2dgames.game.state.FieldState;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.gui.Dialog;

/**
 * 状態
 **/
private enum State {
  None;       // なし
  OpenDialog; // ダイアログを開いている
  Battle;     // バトル実行中
  Item;       // アイテム
  Money;      // お金を拾う

  // 終了
  End;
}

/**
 * フィールドイベント管理
 **/
class FieldEventMgr {

  // ■定数
  // 返却コード
  public static inline var RET_NONE:Int      = 0;
  public static inline var RET_NEXTSTAGE:Int = 1;
  public static inline var RET_GAMEOVER:Int  = 2;

  // 状態
  var _state:State = State.None;

  // 親
  var _flxState:FieldState;

  // イベント種別
  var _evType:FieldEvent = FieldEvent.None;

  // 返却コード
  var _resultCode:Int = RET_NONE;
  public var resultCode(get, never):Int;
  private function get_resultCode() {
    return _resultCode;
  }

  // 出現アイテム
  var _csvFieldItem:CsvLoader;

  /**
   * コンストラクタ
   **/
  public function new(flxState:FieldState) {
    _flxState = flxState;

    // CSV読み込み
    _csvFieldItem = new CsvLoader(Reg.PATH_CSV_FIELD_ITEM);
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }

  /**
   * 状態遷移
   **/
  private function _change(s:State):Void {
    _state = s;
  }

  /**
   * イベント開始
   **/
  public function start(ev:FieldEvent):Void {

    _resultCode = RET_NONE;
    _evType = ev;

    switch(_evType) {
      case FieldEvent.Goal:
        // ゴールにたどり着いた
        _change(State.OpenDialog);
        Dialog.open(_flxState, Dialog.OK, 'ゲームクリア！', null, function(btnID) {
          _resultCode = RET_NEXTSTAGE;
          _change(State.End);
        });

      case FieldEvent.Enemy:
        // バトル
        _change(State.OpenDialog);
        Snd.playSe("roar");
        // 戻り値初期化
        _flxState.setBattleResult(BtlLogicPlayer.BTL_END_NONE);

        // ダイアログを開く
        Dialog.open(_flxState, Dialog.OK, 'モンスターに遭遇した！', null, function(btnID) {
          // バトル開始
          _change(State.Battle);

          var nBtl = FlxRandom.intRanged(1, 4);
          Global.setStage(nBtl);
          _flxState.openSubState(new BattleState());
        });

      case FieldEvent.Item:
        // アイテム
        _change(State.Item);

      case FieldEvent.None:
        // お金を拾う
        _change(State.Money);

      case FieldEvent.Start:
        throw '不正なイベントタイプ ${_evType}';
    }
  }

  /**
   * イベント更新
   **/
  public function proc():Void {

    switch(_state) {
      case State.None:

      case State.OpenDialog:

      case State.Battle:
        _procBattle();

      case State.Item:
        _procItem();

      case State.Money:
        _procMoney();

      case State.End:
    }
  }

  /**
   * バトル実行中
   **/
  private function _procBattle():Void {

    switch(_flxState.retBattle) {
      case BtlLogicPlayer.BTL_END_NONE:
        // バトル実行中

      case BtlLogicPlayer.BTL_END_LOSE:
        // ゲームオーバー
        _change(State.End);
        _resultCode = RET_GAMEOVER;

      default:
        // バトル勝利
        _change(State.End);
    }
  }

  /**
   * アイテム取得
   **/
  private function _procItem():Void {
    _change(State.OpenDialog);

    // スキル入手チェック
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

      var itemID = Generator.getItem(_csvFieldItem);
      var item = new ItemData(itemID);
      Inventory.push(item);
      var name = ItemUtil.getName(item);
      msg = '${name}を見つけた';
    }

    Snd.playSe("powerup");

    Dialog.open(_flxState, Dialog.OK, msg, null, function(btnID:Int) {
      _change(State.End);
    });
  }

  /**
   * お金取得
   **/
  private function _procMoney():Void {

    _change(State.OpenDialog);

    var money = FlxRandom.intRanged(1, 5);
    Global.addMoney(money);
    // SE再生
    Snd.playSe("coin");

    Dialog.open(_flxState, Dialog.OK, '${money}G拾った', null, function(btnID:Int) {

      _change(State.End);
    });
  }
}
