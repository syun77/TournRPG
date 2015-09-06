package jp_2dgames.game.actor;

import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.BtlCmdUtil.BtlCmd;
import flixel.FlxG;
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

  static inline var TIMER_SHAKE:Int = 120;

  // 状態
  var _state:State     = State.None;
  var _statePrev:State = State.None;

  // 要素番号
  var _idx:Int = 0;

  // 実行コマンド
  var _cmd:BtlCmd = BtlCmd.None;

  // 開始座標
  var _xstart:Float = 0;
  var _ystart:Float = 0;

  // ダメージ時の揺れ
  var _tShake:Float = 0;

  // アニメーションタイマー
  var _tAnime:Int = 0;

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
  // 力
  public var str(get, never):Int;
  private function get_str() {
    return _param.str;
  }
  // 体力
  public var vit(get, never):Int;
  private function get_vit() {
    return _param.vit;
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
   * HP回復
   * @param val 回復する値
   **/
  public function addHp(val:Int):Void {
    _param.hp += val;
    _clampHp();
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
    if(params != null) {
      _param.copy(params);
    }

    if(_group == PartyGroup.Enemy) {
      // 敵の場合の処理
      _initEnemy();
    }
    else {
      FlxG.watch.add(this, "_cmd");
    }
  }

  /**
   * 敵の初期化処理
   **/
  private function _initEnemy():Void {

    // ID取得
    var id = _param.id;

    // 画像読み込み
    var image = EnemyInfo.getString(id, "image");
    var path = Reg.getEnemyImagePath(image);
    loadGraphic(path);

    // パラメータ設定
    EnemyInfo.setParam(_param, id);

    // 名前を設定
    _name = EnemyInfo.getString(id, "name");

    // 表示する
    visible = true;
  }

  public function setName(str:String):Void {
    _name = str;
  }

  /**
   * 座標を設定する
   **/
  public function setDrawPosition(xstart:Float, ystart:Float):Void {
    _xstart = xstart;
    _ystart = ystart;
    x = xstart;
    y = ystart;
  }

  /**
   * コマンドを設定する
   **/
  public function setCommand(cmd:BtlCmd):Void {
    _cmd = cmd;
  }
  public function resetCommand():Void {
    _cmd = BtlCmd.None;
  }

  /**
   * 攻撃対象をランダムで選ぶ
   **/
  private function _attackRandom():Void {
    // 対抗グループを取得する
    var grp = PartyGroupUtil.getAgaint(_group);

    // 攻撃対象を取得する
    var target = ActorMgr.random(grp);
    if(target != null) {
      // ダメージ計算
      var val = Calc.damage(this, target);
      target.damage(val);
    }
  }

  /**
   * 行動実行
   **/
  public function exec():BtlCmd {

    switch(_cmd) {
      case BtlCmd.None:
        // 通常ここにくることはない

      case BtlCmd.Attack(id):
        // 通常攻撃
        _attackRandom();

      case BtlCmd.Skill(id):
        // スキルを使う

      case BtlCmd.Item(id):
        // アイテムを使う
        Inventory.useItem(this, id);

      case BtlCmd.Escape:
    }

    // 行動完了
    _change(State.ActEnd);

    return _cmd;
  }

  /**
   * ダメージを与える
   **/
  public function damage(v:Int):Bool {
    _param.hp -= v;
    _clampHp();

    // ダメージメッセージ表示
    if(_group == PartyGroup.Player) {
      // プレイヤーにダメージ
      Message.push2(Msg.DAMAGE_PLAYER, [_name, v]);
      // 画面を揺らす
      var intensity = 0.1 * v / hpmax;
      var duration  = 0.3;
      FlxG.camera.shake(intensity, duration);
    }
    else {
      // 敵にダメージ
      Message.push2(Msg.DAMAGE_ENEMY, [_name, v]);
      // 揺らす
      _tShake = TIMER_SHAKE;
    }

    return isDead();
  }

  public function actBegin() {
    _change(State.ActBegin);
    // 行動開始
    Message.push2(Msg.ATTACK_BEGIN, [_name]);
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

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _tAnime++;

    _updateShake();
  }

  /**
   * 揺らす
   **/
  private function _updateShake():Void {
    if(_group != PartyGroup.Enemy) {
      return;
    }

    x = _xstart;
    if(_tShake > 0) {
      _tShake *= 0.9;
      var xsign = if(_tAnime%4 < 2) 1 else -1;
      x = _xstart + (_tShake * xsign * 0.2);
    }
  }

  /**
   * AIで行動を決定する
   **/
  public function requestAI():Void {
    _cmd = BtlCmd.Attack(0);
  }
}
