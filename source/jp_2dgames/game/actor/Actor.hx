package jp_2dgames.game.actor;

import jp_2dgames.lib.TextUtil;
import flixel.util.FlxColorUtil;
import jp_2dgames.game.gui.BtlCharaUI;
import jp_2dgames.game.gui.HpBar;
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
  static inline var TIMER_ANIM_COLOR:Int = 60;

  // 危険状態
  public static inline var HP_NONE:Int = 0; // 通常
  public static inline var HP_WARN:Int = 1; // 警告
  public static inline var HP_DANGER:Int = 2; // 危険

  public static inline var HPBAR_WIDTH = (BtlCharaUI.BAR_HPMP_WIDTH * 1.5);
  public static inline var HPBAR_HEIGHT = (BtlCharaUI.BAR_HPMP_HEIGHT * 2);

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

  // 色替え演出
  var _tAnimColor:Int = 0;
  var _animColor:Int  = 0;

  // AI
  var _ai:ActorAI;

  // グループ
  var _group:BtlGroup;
  public var group(get, never):BtlGroup;
  private function get_group() {
    return _group;
  }

  // プレイヤーかどうか
  var _bPlayer:Bool = false;
  public function isPlayer():Bool {
    return _bPlayer;
  }
  public function setPlayer(b:Bool):Void {
    _bPlayer = b;
  }

  // 名前
  public var name(get, never):String;
  private function get_name() {
    return _param.name;
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
  public function addHpMax(v:Int):Void {
    _param.hpmax += v;
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
  public function addStr(v:Int):Void {
    _param.str += v;
  }
  // 体力
  public var vit(get, never):Int;
  private function get_vit() {
    return _param.vit;
  }
  public function addVit(v:Int):Void {
    _param.vit += v;
  }
  // 素早さ
  public var agi(get, never):Int;
  private function get_agi() {
    return _param.agi;
  }
  public function addAgi(v:Int):Void {
    _param.agi += v;
  }
  // 魔力
  public var mag(get, never):Int;
  private function get_mag() {
    return _param.mag;
  }
  public function addMag(v:Int):Void {
    _param.mag += v;
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
  // 食糧
  public var food(get, never):Int;
  private function get_food() {
    return _param.food;
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
  // バッドステータスの威力値
  private var _badstatusVal:Int = 0;
  public var badstatusVal(get, never):Int;
  private function get_badstatusVal() {
    return _badstatusVal;
  }
  // バフ
  public var buffAtk(get, never):Int;
  private function get_buffAtk() {
    return _param.buffAtk;
  }
  public var buffDef(get, never):Int;
  private function get_buffDef() {
    return _param.buffDef;
  }
  public var buffSpd(get, never):Int;
  private function get_buffSpd() {
    return _param.buffSpd;
  }
  public function addBuffAtk(v:Int):Void {
    _param.buffAtk += v;
  }
  public function addBuffDef(v:Int):Void {
    _param.buffDef += v;
  }
  public function addBuffSpd(v:Int):Void {
    _param.buffSpd += v;
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

  // HPゲージ
  var _hpBar:HpBar;
  public var hpBar(get, never):HpBar;
  private function get_hpBar() {
    return _hpBar;
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
  public function clampHp():Void {
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
  public function clampMp():Void {
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
    clampHp();
  }

  /**
   * MP回復
   * @param val 回復する値
   **/
  public function recoverMp(val:Int):Void {
    _param.mp += val;
    clampMp();
  }

  /**
   * 危険状態の取得
   **/
  public function getDanger():Int {
    var ratio = hpratio;
    if(ratio < 0.3) {
      // 30%以下は危険
      return HP_DANGER;
    }
    if(ratio < 0.5) {
      // 50%以下は警告
      return HP_WARN;
    }
    // 問題なし
    return HP_NONE;
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

    // HPゲージ
    {
      var w = Std.int(HPBAR_WIDTH);
      var h = Std.int(HPBAR_HEIGHT);
      _hpBar = new HpBar(0, 0, w, h);
    }

    // 非表示にしておく
    kill();
    visible = false;
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    _bstIcon.kill();
    _hpBar.kill();
    super.kill();
  }

  /**
   * パラメータをコピーする
   **/
  public function copy(actor:Actor):Void {
    _idx = actor._idx;
    _cmd = actor.cmd;
    init(actor.group, actor.param, false);
    _badstatus = actor.badstatus;
    _badstatusVal = actor.badstatusVal;
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
      _hpBar.revive();
    }
    else {
      // プレイヤーの場合の処理
      if(bCreate) {
        if(param.id > 0 && isPlayer() == false) {
          // NPCの初期化
          _initNpc();
        }
      }
    }

    _bPlayer = false;
    color = FlxColor.WHITE;
    _tAnimColor = 0;
    _animColor  = FlxColor.WHITE;

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
   * 色変えアニメーション開始
   **/
  public function startAnimColor(c:Int):Void {
    _tAnimColor = TIMER_ANIM_COLOR;
    _animColor = c;
  }

  /**
   * バステ付着
   * @param bst    付着するバッドステータス
   * @param val    バッドステータスの威力値
   * @param bForce 強制付着フラグ
   * @return 付着したらtrue
   **/
  public function adhereBadStatus(bst:BadStatus, val:Int, bForce:Bool=false):Bool {
    if(bForce || BadStatusUtil.isAdhere(badstatus, bst)) {
      // 付着できる
      _badstatus = bst;
      _badstatusVal = val;
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
   * NPCの初期化処理
   **/
  private function _initNpc():Void {

    // ID取得
    var id = _param.id;

    // パラメータ設定
    NpcInfo.setParam(_param, id);

    // AIスクリプト読み込み
    var script = Reg.getNpcScriptPath(id);
    _ai = new ActorAI(this, script);
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
    _param.name = str;
  }

  /**
   * 座標を設定する
   **/
  public function setDrawPosition(xstart:Float, ystart:Float):Void {
    _xstart = xstart;
    _ystart = ystart;
    x = xstart;
    y = ystart;

    _bstIcon.x = xcenter - HPBAR_WIDTH/2;
    _bstIcon.y = bottom + 12;

    _hpBar.x = xcenter - HPBAR_WIDTH/2;
    _hpBar.y = y + height + 4;
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
    clampHp();

    return isDead();
  }

  /**
   * 最大HPの割合でダメージを与える
   **/
  public function damageRatio(v:Float):Bool {
    var val = Std.int(hpmax * v);
    return damage(val);
  }

  public function damageMp(v:Int):Void {
    _param.mp -= v;
    clampMp();
  }

  /**
   * HPが最大かどうか
   **/
  public function isHpMax():Bool {
    return (_param.hp == _param.hpmax);
  }

  /**
   * 揺らす
   **/
  public function shake(ratio:Float=1.0):Void {
    _tShake = Std.int(TIMER_SHAKE * ratio);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _tAnime++;

    // 揺れ更新
    _updateShake();

    // 色変えアニメ更新
    _updateAnimColor();

    // HPゲージ更新
    _updateHpBar();
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
   * 色変えアニメーション更新
   **/
  private function _updateAnimColor():Void {
    if(_tAnimColor > 0) {
      _tAnimColor--;
      color = FlxColorUtil.interpolateColor(FlxColor.WHITE, _animColor, TIMER_ANIM_COLOR, _tAnimColor);
      if(_tAnimColor == 0) {
        color = FlxColor.WHITE;
      }
    }
  }

  /**
   * HPゲージ更新
   **/
  private function _updateHpBar():Void {
    if(_group != BtlGroup.Enemy) {
      return;
    }

    _hpBar.setPercent(100 * hpratio);
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
