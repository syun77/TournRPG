package jp_2dgames.game;

import jp_2dgames.game.PartyGroupUtil;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

private enum State {
  Standby;
  TurnEnd;
}

/**
 * キャラクター
 **/
class Actor extends FlxSprite {

  // グループ
  var _group:PartyGroup;

  // 状態
  var _state:State;

  // 要素番号
  var _idx:Int = 0;

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
   * コンストラクタ
   **/
  public function new(id:Int) {
    super();

    _idx = id;
    _param = new Params();

    // 非表示にしておく
    kill();
    visible = false;

    _state = State.Standby;
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

  /**
   * 行動実行
   **/
  public function exec():Void {
    damage(5);
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

  public function actEnd() {
    _state = State.TurnEnd;
  }
  public function isTurnEnd():Bool {
    return _state == State.TurnEnd;
  }
  public function turnEnd() {
    _state = State.Standby;
  }
}
