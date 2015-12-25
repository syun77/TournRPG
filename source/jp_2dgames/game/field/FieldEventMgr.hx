package jp_2dgames.game.field;

import jp_2dgames.game.actor.PartyActorMgr;
import jp_2dgames.game.actor.PartyMgr;
import jp_2dgames.game.gui.message.UIMsg;
import jp_2dgames.game.btl.BtlMgr.BtlMgrParam;
import jp_2dgames.game.btl.types.BtlEndResult;
import jp_2dgames.game.btl.types.BtlEndType;
import flixel.util.FlxColor;
import flixel.FlxG;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.util.Generator;
import flixel.util.FlxRandom;
import jp_2dgames.game.state.BattleState;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
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
  public static inline var RET_NONE:Int     = 0;
  public static inline var RET_GOAL:Int     = 1; // ゴール
  public static inline var RET_GAMEOVER:Int = 2; // ゲームオーバー
  public static inline var RET_SHOP:Int     = 3; // ショップ

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

  // パーティ情報
  var _party:PartyActorMgr = null;

  /**
   * コンストラクタ
   **/
  public function new(flxState:FieldState, party:PartyActorMgr) {
    _flxState = flxState;
    _party = party;

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
  public function start(node:FieldNode):Void {

    // 初期化
    _init(node.evType);

    switch(_evType) {
      case FieldEvent.Goal:
        // ゴールにたどり着いた
        _resultCode = RET_GOAL;
        _change(State.End);

      case FieldEvent.Enemy:
        // バトル
        startBattle(node, null);

      case FieldEvent.Item:
        // アイテム
        _change(State.Item);

      case FieldEvent.Random:
        // お金を拾う
        _change(State.Money);

      case FieldEvent.Shop:
        // ショップ
        _resultCode = RET_SHOP;
        _change(State.Shop);

      case FieldEvent.None:
        // 何も起こらない
        _change(State.End);

    }
  }

  /**
   * バトル開始
   * @param node 地形ノード情報
   * @param foe F.O.E.とのバトルの場合
   **/
  public function startBattle(node:FieldNode, foe:FieldFoe=null):Void {

    // 初期化
    _init(FieldEvent.Enemy);
    _foe = foe;

    _change(State.OpenDialog);
    Snd.playSe("roar");

    // ダイアログを開く
    Dialog.open(_flxState, Dialog.OK, UIMsg.get(UIMsg.MONSTER_APPEAR), null, function(btnID) {
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
      FlxG.camera.fade(FlxColor.WHITE, 0.3, false, function() {
        // フェードしてからバトル開始
        FlxG.camera.fade(FlxColor.WHITE, 0.1, true, null, true);
        // バトルパラメータ生成
        var param = new BtlMgrParam();
        param.party.copyFromActor(_party);
        param.enemyGroupID = nBtl;
        param.effect = node.eftType;
        _flxState.openSubState(new BattleState(param, _cbBattleEnd));
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
   * バトル終了時のコールバック
   **/
  private function _cbBattleEnd(btlEnd:BtlEndResult):Void {

    // パーティパラメータコピー
    _party.copyFromParam(btlEnd.party);

    switch(btlEnd.type) {
      case BtlEndType.Win:
        // バトル勝利
        if(_foe != null) {
          // F.O.E.バトルの場合は消しておく
          _foe.kill();
        }
        _bBtlEnd = true;
        _change(State.End);

      case BtlEndType.Lose:
        // ゲームオーバー
        _resultCode = RET_GAMEOVER;
        _bBtlEnd = true;
        _change(State.End);

      case BtlEndType.Escape:
        // 逃走
        _bBtlEnd = true;
        _change(State.End);

      default:
        throw 'Error: 不正なバトル終了戻り値 ${btlEnd}';
    }
  }

  /**
   * アイテム取得
   **/
  private function _procItem():Void {
    _change(State.OpenDialog);

    var itemID = Generator.getItem(_csvFieldItem);
    var item = new ItemData(itemID);
    Inventory.push(item);
    var name = ItemUtil.getName(item);
    var msg = UIMsg.get2(UIMsg.ITEM_FOUND, [name]);

    Snd.playSe("powerup2");

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

    var msg = UIMsg.get2(UIMsg.MONEY_FOUND, [money]);
    Dialog.open(_flxState, Dialog.OK, msg, null, function(btnID:Int) {

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
