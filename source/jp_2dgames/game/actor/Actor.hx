package jp_2dgames.game.actor;

import jp_2dgames.game.gui.BadStatusUI;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import flixel.util.FlxColor;
import jp_2dgames.game.btl.types.BtlCmd;
import jp_2dgames.game.btl.BtlGroupUtil;
import flixel.FlxSprite;

private enum State {
  None;     // なし
  Standby;  // 待機

  // ターン終了
  TurnEnd;
}

/**
 * キャラクター
 **/
class Actor extends FlxSprite {

  // ■定数
  // 揺れタイマー
  static inline var TIMER_SHAKE:Int = 120;

  // ■メンバ変数
  // 状態
  var _state:State     = State.None;
  var _statePrev:State = State.None;

  // 要素番号
  var _idx:Int = 0;

  // 実行コマンド
  var _cmd:BtlCmd = BtlCmd.None;
  public var cmd(get, never):BtlCmd;
  private function get_cmd() {
    return _cmd;
  }

  // 開始座標
  var _xstart:Float = 0;
  public var xstart(get, never):Float;
  private function get_xstart() {
    return _xstart;
  }
  var _ystart:Float = 0;
  public var ystart(get, never):Float;
  private function get_ystart() {
    return _ystart;
  }

  // ダメージ時の揺れ
  var _tShake:Float = 0;

  // アニメーションタイマー
  var _tAnime:Int = 0;

  // AI
  var _ai:ActorAI;

  // グループ
  var _group:BtlGroup;
  public var group(get, never):BtlGroup;
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
  // レベル
  public var lv(get, never):Int;
  private function get_lv() {
    return _param.lv;
  }
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
  // MP
  public var mp(get, never):Int;
  private function get_mp() {
    return _param.mp;
  }
  // 最大MP
  public var mpmax(get, never):Int;
  private function get_mpmax() {
    return _param.mpmax;
  }
  public var mpratio(get, never):Float;
  private function get_mpratio() {
    return _param.mp / _param.mpmax;
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

  // 所持金
  public var money(get, never):Int;
  private function get_money() {
    return _param.money;
  }
  // 経験値
  public var xp(get, never):Int;
  private function get_xp() {
    return _param.xp;
  }
  // パラメータを取得する
  public var param(get, never):Params;
  private function get_param() {
    return _param;
  }
  // バッドステータス
  private var _badstatus:BadStatus = BadStatus.None;
  public var badstatus(get, never):BadStatus;
  private function get_badstatus() {
    return _badstatus;
  }
  // バッドステータスになってからの経過ターン数
  private var _badstatusTurn:Int = 0;
  public var badstatusTurn(get, never):Int;
  private function get_badstatusTurn() {
    return _badstatusTurn;
  }

  // 中心座標を取得する
  public var xcenter(get, never):Float;
  private function get_xcenter() {
    return x + origin.x;
  }
  public var ycenter(get, never):Float;
  private function get_ycenter() {
    return y + origin.y;
  }
  // 一番上の座標を取得する
  public var top(get, never):Float;
  private function get_top() {
    return y;
  }
  // 一番下の座標を取得する
  public var bottom(get, never):Float;
  private function get_bottom() {
    return y + height;
  }

  // バッドステータスアイコン
  private var _bstIcon:BadStatusUI;
  public var bstIcon(get, never):BadStatusUI;
  private function get_bstIcon() {
    return _bstIcon;
  }

  /**
   * 経験値を増やす
   **/
  public function addXp(val:Int):Void {
    _param.xp += val;
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
   * MPが最大値・最小値を超えないように丸める
   **/
  private function _clampMp():Void {
    if(mp < 0) {
      _param.mp = 0;
    }
    if(mp > mpmax) {
      _param.mp = mpmax;
    }
  }

  /**
   * HP回復
   * @param val 回復する値
   **/
  public function recoverHp(val:Int):Void {
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

    _change(State.Standby);

    // バステアイコン
    _bstIcon = new BadStatusUI(0, 0);

    // 非表示にしておく
    kill();
    visible = false;
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    _bstIcon.kill();
    super.kill();
  }

  /**
   * パラメータをコピーする
   **/
  public function copy(actor:Actor):Void {
    _idx = actor._idx;
    _cmd = actor.cmd;
    _name = actor.name;
    init(actor.group, actor.param, false);
    _badstatus = actor.badstatus;
    _badstatusTurn = actor.badstatusTurn;
  }

  /**
   * 初期化
   **/
  public function init(group:BtlGroup, params:Params, bCreate:Bool=true):Void {
    ID = _idx + BtlGroupUtil.getOffsetID(group);
    _group = group;
    if(params != null) {
      _param.copy(params);
    }

    if(_group == BtlGroup.Enemy) {
      // 敵の場合の処理
      if(bCreate) {
        _initEnemy();
      }
    }

    color = FlxColor.WHITE;

    // バッドステータス初期化
    _badstatus = BadStatus.None;
    _bstIcon.revive();
    _bstIcon.set(_badstatus);
  }

  /**
   * 色を変える
   **/
  public function changeColor(c:Int):Void {
    color = c;
  }

  /**
   * バステ付着
   * @param bst    付着するバッドステータス
   * @param bForce 強制付着フラグ
   * @return 付着したらtrue
   **/
  public function adhereBadStatus(bst:BadStatus, bForce:Bool=false):Bool {
    if(bForce || BadStatusUtil.isAdhere(badstatus, bst)) {
      // 付着できる
      _badstatus = bst;
      // 付着開始ターン数
      _badstatusTurn = 0;
      if(group == BtlGroup.Enemy) {
        // バステアイコン表示
        _bstIcon.set(bst);
      }
      return true;
    }

    return false;
  }

  /**
   * バステ回復
   **/
  public function cureBadStatus():Void {
    _badstatus = BadStatus.None;
    _badstatusTurn = 0;
    if(group == BtlGroup.Enemy) {
      // バステアイコン非表示
      _bstIcon.set(BadStatus.None);
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

    // AIスクリプト読み込み
    var ai = EnemyInfo.getString(id, "ai");
    var script = Reg.getEnemyScriptPath(ai);
    _ai = new ActorAI(this, script);
    // TODO:
//    _ai.setLog(true);
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

    _bstIcon.x = xcenter;
    _bstIcon.y = ycenter;
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
   * ダメージを与える
   **/
  public function damage(v:Int):Bool {
    _param.hp -= v;
    _clampHp();

    return isDead();
  }

  public function damageMp(v:Int):Void {
    _param.mp -= v;
    _clampMp();
  }

  /**
   * 揺らす
   **/
  public function shake():Void {
    _tShake = TIMER_SHAKE;
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
    if(_group != BtlGroup.Enemy) {
      return;
    }

    x = _xstart;
    if(_tShake > 0) {
      _tShake *= 0.9;
      if(_tShake < 1) {
        _tShake = 0;
      }
      var xsign = if(_tAnime%4 < 2) 1 else -1;
      x = _xstart + (_tShake * xsign * 0.2);
    }
  }

  /**
   * AIで行動を決定する
   **/
  public function requestAI():Void {
    _ai.exec();
    _cmd = _ai.cmd;
  }

  /**
   * レベルアップのパラメータ上昇
   **/
  private function _levelup():Void {
    _param.hpmax += PlayerInfo.get(lv, "hp");
    _param.str   += PlayerInfo.get(lv, "str");
    _param.vit   += PlayerInfo.get(lv, "vit");

  }

  /**
   * レベルアップのチェック
   **/
  public function checkLevelup():Bool {
    if(lv >= 99) {
      // レベル99で打ち止め
      return false;
    }

    var bLevelup = false;
    // 次のレベルに必要な経験値を取得
    var nextXp = PlayerInfo.get(lv+1, "exp");
    while(xp >= nextXp) {
      // レベルアップ
      _param.lv++;
      // パラメータ上昇
      _levelup();

      bLevelup = true;
      if(lv >= 99) {
        // レベル99で打ち止め
        break;
      }

      nextXp = PlayerInfo.get(lv+1, "exp");
    }

    return bLevelup;
  }

  /**
   * ターン終了
   **/
  public function turnEnd():Void {

    switch(badstatus) {
      case BadStatus.None:
      case BadStatus.Dead:
        // 回復しない
      default:
        // バッドステータス経過ターンを進める
        _badstatusTurn++;
    }
  }
}
