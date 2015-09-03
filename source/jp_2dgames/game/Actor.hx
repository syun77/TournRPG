package jp_2dgames.game;

import flixel.FlxG;
import flixel.tile.FlxTile;
import flixel.util.FlxTimer;
import jp_2dgames.game.PartyGroupUtil;
import flixel.FlxSprite;

private enum State {
  None;     // なし
  Standby;  // 待機

  // 行動
  ActBegin; // 開始
  Act;      // 実行中
  ActEnd;   // 終了

  // ターン終了
  TurnEnd;
}

/**
 * キャラクター
 **/
class Actor extends FlxSprite {

  // 状態
  var _state:State     = State.None;
  var _statePrev:State = State.None;

  // 要素番号
  var _idx:Int = 0;

  // グループ
  var _group:PartyGroup;
  public var group(get, never):PartyGroup;
  private function get_group() {
    return _group;
  }

  // 名前
  var _name:String;
  public var name(get, never):String;
  private function get_name() {
    return _name;
  }
  var _param:Params;
  // HP
  public var hp(get, never):Int;
  private function get_hp() {
    return _param.hp;
  }
  // 最大HP
  public var hpmax(get, never):Int;
  private function get_hpmax() {
    return _param.hpmax;
  }
  public var hpratio(get, never):Float;
  private function get_hpratio() {
    return _param.hp / _param.hpmax;
  }
  // 素早さ
  public var agi(get, never):Int;
  private function get_agi() {
    return _param.agi;
  }

  /**
   * HPが最大値・最小値を超えないように丸める
   **/
  private function _clampHp():Void {
    if(hp < 0) {
      _param.hp = 0;
    }
    if(hp > hpmax) {
      _param.hp = hpmax;
    }
  }

  /**
   * 死亡したかどうか
   **/
  public function isDead():Bool {
    return hp <= 0;
  }

  /**
   * 状態遷移
   **/
  private function _change(s:State):Void {
    _state = s;
  }

  /**
   * コンストラクタ
   **/
  public function new(id:Int) {
    super();

    _idx = id;
    _param = new Params();

    // 非表示にしておく
    kill();
    visible = false;

    _change(State.Standby);

    if(id < 2) {
      FlxG.watch.add(this, "_state");
    }
  }

  /**
   * 初期化
   **/
  public function init(group:PartyGroup, params:Params):Void {
    ID = _idx + PartyGroupUtil.getOffsetID(group);
    _group = group;
    _param.copy(params);
  }
  public function setName(str:String):Void {
    _name = str;
  }

  private function _attackRandom():Void {
    // 対抗グループを取得する
    var grp = PartyGroupUtil.getAgaint(_group);

    // 攻撃対象を取得する
    var actor = ActorMgr.random(grp);
    if(actor != null) {
      var val = 10;
      if(grp == PartyGroup.Enemy) {
        val *= 50;
      }
      actor.damage(val);
    }
  }

  /**
   * 行動実行
   **/
  public function exec():Void {

    switch(_state) {
      case State.None:
      case State.Standby:
      case State.ActBegin:

      case State.Act:
        _attackRandom();
        _change(State.ActEnd);

      case State.ActEnd:
      case State.TurnEnd:
    }

  }

  /**
   * ダメージを与える
   **/
  public function damage(v:Int):Bool {
    _param.hp -= v;
    _clampHp();

    Message.push2(1, [_name, v]);

    return isDead();
  }

  public function actBegin() {
    _change(State.ActBegin);
    // 行動開始
    Message.push2(3, [_name]);
    _change(State.Act);
  }
  public function isActEnd():Bool {
    return _state == State.ActEnd;
  }
  public function actEnd() {
    _change(State.TurnEnd);
  }
  public function isTurnEnd():Bool {
    return _state == State.TurnEnd;
  }
  public function turnEnd() {
    _state = State.Standby;
  }
}
