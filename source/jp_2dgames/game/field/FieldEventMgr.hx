package jp_2dgames.game.field;

import flixel.util.FlxColor;
import flixel.FlxG;
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
  Shop;       // ショップ

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
  public static inline var RET_GOAL:Int = 1;
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

  // 敵グループ
  var _csvEnemyGroup:CsvLoader;

  // バトル終了後かどうか
  var _bBtlEnd:Bool = false;

  // F.O.E.
  var _foe:FieldFoe = null;

  /**
   * コンストラクタ
   **/
  public function new(flxState:FieldState) {
    _flxState = flxState;

    // CSV読み込み
    _csvFieldItem  = new CsvLoader(Reg.PATH_CSV_FIELD_ITEM);
    _csvEnemyGroup = new CsvLoader(Reg.PATH_CSV_ENEMY_GROUP);
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }

  public function isBtlEnd():Bool {
    return _bBtlEnd;
  }

  /**
   * 状態遷移
   **/
  private function _change(s:State):Void {
    _state = s;
  }

  private function _init(ev:FieldEvent):Void {
    _resultCode = RET_NONE;
    _evType = ev;
    _bBtlEnd = false;

  }

  /**
   * イベント開始
   **/
  public function start(ev:FieldEvent):Void {

    // 初期化
    _init(ev);

    switch(_evType) {
      case FieldEvent.Goal:
        // ゴールにたどり着いた
        _resultCode = RET_GOAL;
        _change(State.End);

      case FieldEvent.Enemy:
        // バトル
        startBattle(null);

      case FieldEvent.Item:
        // アイテム
        _change(State.Item);

      case FieldEvent.Random:
        // お金を拾う
        _change(State.Money);

      case FieldEvent.Shop:
        // ショップ
        _change(State.Shop);

      case FieldEvent.None:
        // 何も起こらない
        _change(State.End);

    }
  }

  /**
   * バトル開始
   * @param foe F.O.E.とのバトルの場合
   **/
  public function startBattle(foe:FieldFoe=null):Void {

    // 初期化
    _init(FieldEvent.Enemy);
    _foe = foe;

    _change(State.OpenDialog);
    Snd.playSe("roar");
    // 戻り値初期化
    _flxState.setBattleResult(BtlLogicPlayer.BTL_END_NONE);

    // ダイアログを開く
    Dialog.open(_flxState, Dialog.OK, 'モンスターに遭遇した！', null, function(btnID) {
      // バトル開始
      _change(State.Battle);

      var nBtl = 1;
      if(_foe != null) {
        // F.O.E.バトル
        nBtl = _foe.groupID;
      }
      else {
        // 通常バトル
        nBtl = Generator.getEnemyGroup(_csvEnemyGroup);
      }
      Global.setEnemyGroup(nBtl);
      FlxG.camera.fade(FlxColor.WHITE, 0.3, false, function() {
        // フェードしてからバトル開始
        FlxG.camera.fade(FlxColor.WHITE, 0.1, true, null, true);
        _flxState.openSubState(new BattleState());
      });
    });
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

      case State.Shop:
        _procShop();

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

      case BtlLogicPlayer.BTL_END_WIN:
        // バトル勝利
        if(_foe != null) {
          // F.O.E.バトルの場合は消しておく
          _foe.kill();
        }
        _bBtlEnd = true;
        _change(State.End);

      case BtlLogicPlayer.BTL_END_LOSE:
        // ゲームオーバー
        _resultCode = RET_GAMEOVER;
        _bBtlEnd = true;
        _change(State.End);

      case BtlLogicPlayer.BTL_END_ESCAPE:
        // 逃走
        _bBtlEnd = true;
        _change(State.End);

      default:
        throw 'Error: 不正なバトル終了戻り値 ${_flxState.retBattle}';
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

  /**
   * ショップ
   **/
  private function _procShop():Void {

    // TODO: 未実装
    _change(State.End);
  }
}
