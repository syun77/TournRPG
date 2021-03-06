package jp_2dgames.game.field;

import jp_2dgames.game.field.FieldParticle;
import jp_2dgames.game.field.FieldEffectUtil.FieldEffect;
import flixel.util.FlxRandom;
import jp_2dgames.lib.MyMath;
import flixel.text.FlxText;
import flixel.FlxG;
import haxe.ds.ArraySort;
import flixel.util.FlxMath;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * フィールドノード
 **/
class FieldNode extends FlxSprite {

  // ■定数
  // ノードの半径
  public static inline var RADIUS:Int = 16;

  private static inline var ANIME_REACHABLE_NOFOOT    = "1"; // 到達可能 / 未踏破
  private static inline var ANIME_NONREACHABLE_NOFOOT = "2"; // 到達不可 / 未踏破
  private static inline var ANIME_REACHABLE_FOOT      = "3"; // 到達可能 / 踏破済み
  private static inline var ANIME_NONREACHABLE_FOOT   = "4"; // 到達不可 / 踏破済み

  // ■管理オブジェクト
  static var _parent:FlxTypedGroup<FieldNode> = null;

  /**
   * 生成
   **/
  public static function createParent(state:FlxState):Void {
    _parent = new FlxTypedGroup<FieldNode>(64);
    state.add(_parent);
    for(i in 0..._parent.maxSize) {
      var node = new FieldNode(i);
      state.add(node.txtDetail);
      _parent.add(node);
    }
  }

  /**
   * 破棄
   **/
  public static function destroyParent():Void {
    _parent = null;
  }

  /**
   * 追加
   **/
  public static function add(X:Float, Y:Float, evType:FieldEvent, eftType:FieldEffect):FieldNode {
    var node:FieldNode = _parent.recycle();
    node.init(X, Y, evType, eftType);
    return node;
  }

  /**
   * 生存しているノードをすべて実行
   **/
  public static function forEachAlive(func:FieldNode->Void):Void {
    _parent.forEachAlive(func);
  }

  /**
   * 条件に一致するノードを返す
   * @return 一致するノードがなければ null
   **/
  public static function search(func:FieldNode->Bool):FieldNode {
    for(n in _parent.members) {
      if(n.alive == false) {
        continue;
      }

      if(func(n)) {
        return n;
      }
    }

    // 一致するノードなし
    return null;
  }

  /**
   * 指定のノードIDに一致するノードを返す
   **/
  public static function searchFromID(nodeID:Int):FieldNode {
    return search(function(n:FieldNode) {
      return (n.ID == nodeID);
    });
  }

  /**
   * スタート地点のノードを取得する
   **/
  public static function getStartNode():FieldNode {
    return search(function(n:FieldNode) {
      if(n.isStartFlag()) {
        return true;
      }
      return false;
    });
  }

  /**
   * スタート地点のノードを設定する
   **/
  public static function setStartNode(node:FieldNode):Void {
    _parent.forEachAlive(function(n:FieldNode) {
      n.resetStartFlag();
    });

    // スタート地点フラグを設定する
    node.setStartFlag(true);
  }

  /**
   * ノードの存在数を計算する
   **/
  public static function countLiving():Int {
    return _parent.countLiving();
  }

  /**
   * ノードをすべて消す
   **/
  public static function killAll():Void {
    _parent.forEachAlive(function(n:FieldNode) { n.kill(); });
  }

  /**
   * 指定のノードの近くにあるノードのリストを返す
   **/
  public static function getNearestSortedList(node:FieldNode):Array<FieldNode> {

    var ret = new Array<FieldNode>();

    // 対象となるノードへの距離を求める
    _parent.forEachAlive(function(n:FieldNode) {
      if(node.ID == n.ID) {
        // 同一なので対象外
        return;
      }

      // 距離を求める
      n.distance = FlxMath.distanceBetween(node, n);
      ret.push(n);
    });

    // 近い順にソートする
    ArraySort.sort(ret, function(a:FieldNode, b:FieldNode) {
      return Std.int(a.distance - b.distance);
    });

    return ret;
  }

  /**
   * 表示フラグを設定する
   **/
  public static function setVisible(b:Bool):Void {
    _parent.visible = b;
    forEachAlive(function(n:FieldNode) {
      n.txtDetail.visible = b;
    });
  }

  /**
   * 指定のイベント種別のノードをランダムで取得する
   **/
  public static function random(ev:FieldEvent):FieldNode {

    // 抽出
    var list = _parent.members.filter(function(node:FieldNode) {
      return node.evType == ev;
    });
    if(list == null) {
      return null;
    }

    // シャッフルして先頭の要素を返す
    FlxRandom.shuffleArray(list, 3);
    return list[0];
  }

  // ---------------------------------------------
  // ■ここからメンバ変数
  // 中心座標
  public var xcenter(get, never):Float;
  private function get_xcenter() {
    return x + origin.x;
  }
  public var ycenter(get, never):Float;
  private function get_ycenter() {
    return y + origin.y;
  }

  // 距離 (距離でのソート時に使用)
  private var _distance:Float = 0;
  public var distance(get, set):Float;
  private function get_distance() {
    return _distance;
  }
  private function set_distance(d:Float):Float {
    _distance = d;
    return d;
  }

  // イベント種別
  private var _evType:FieldEvent;
  public var evType(get, never):FieldEvent;
  private function get_evType() {
    return _evType;
  }

  // 地形効果
  private var _eftType:FieldEffect;
  public var eftType(get, never):FieldEffect;
  private function get_eftType() {
    return _eftType;
  }

  /**
   * イベントを設定
   **/
  public function setEventType(ev:FieldEvent):Void {
    if(_evType == FieldEvent.Goal) {
      // ゴールは上書きしない
      return;
    }
    if(_evType == FieldEvent.Shop) {
      // ショップは上書きしない
      return;
    }

    _evType = ev;
  }

  /**
   * 地形効果を設定
   **/
  public function setEffectType(eft:FieldEffect):Void {
    _eftType = eft;
  }

  /**
   * スタート地点フラグ
   **/
  private var _bStartFlag:Bool;
  public function resetStartFlag():Void {
    _bStartFlag = false;
  }
  public function setStartFlag(b:Bool):Void {
    _bStartFlag = b;
  }
  public function isStartFlag():Bool {
    return _bStartFlag;
  }

  // ゴールかどうか
  public function isGoal():Bool {
    return _evType == FieldEvent.Goal;
  }

  // ショップかどうか
  public function isShop():Bool {
    return _evType == FieldEvent.Shop;
  }

  // 到達可能かどうか
  private var _reachable:Bool = true;
  public var reachable(get, set):Bool;
  private function get_reachable() {
    return _reachable;
  }
  private function set_reachable(b:Bool) {
    if(b) {
      // 到達できる
      _setColor();
      // 開いたフラグを立てる
      _bOpened = true;
    }
    else {
      // 到達できない
      color = FlxColor.WHITE;
    }

    if(isGoal()) {
      // ゴールは常に表示
      _setColor();
    }

    _reachable = b;

    _playAnime(_reachable, _bFoot);

    return b;
  }

  // 移動可能なノード
  private var _reachableNodes:List<FieldNode>;
  public var reachableNodes(get, never):List<FieldNode>;
  private function get_reachableNodes() {
    return _reachableNodes;
  }

  // 踏破済みかどうか
  private var _bFoot:Bool;
  public var bFoot(get, never):Bool;
  private function get_bFoot() {
    return _bFoot;
  }
  public function setFoot(b:Bool):Void {
    _bFoot = b;
    _playAnime(reachable, _bFoot);
  }

  // 情報を開いたかどうか
  private var _bOpened:Bool;
  public var bOpened(get, never):Bool;
  private function get_bOpened() {
    return _bOpened;
  }
  public function setOpened(b:Bool):Void {
    _bOpened = b;
    if(b) {
      _setColor();
    }
  }

  /**
   * 移動可能なノードを追加
   * @param node 追加するノード
   * @return 追加できたら true
   **/
  public function addReachableNodes(node:FieldNode):Bool {
    for(n in _reachableNodes) {
      if(n.ID == node.ID) {
        // すでに追加済み
        return false;
      }
    }

    _reachableNodes.add(node);
    // 追加できた
    return true;
  }

  /**
   * 移動可能なノードをすべて到達可能にする
   **/
  public function openNodes():Void {
    for(node in _reachableNodes) {
      node.reachable = true;
    }
  }

  /**
   * 詳細説明テキスト
   **/
  private var _txtDetail:FlxText;
  public var txtDetail(get, never):FlxText;
  private function get_txtDetail() {
    return _txtDetail;
  }

  // 詳細テキスト点滅アニメ
  private var _tAnim:Int = 0;

  // ---------------------------------------------
  // ■ここからメンバ関数
  /**
   * コンストラクタ
   **/
  public function new(idx:Int) {
    super();
    ID = idx;
    loadGraphic(Reg.PATH_FIELD_NODE, true);
    animation.add(ANIME_REACHABLE_NOFOOT,    [0], 1);
    animation.add(ANIME_NONREACHABLE_NOFOOT, [1], 1);
    animation.add(ANIME_REACHABLE_FOOT,      [2], 1);
    animation.add(ANIME_NONREACHABLE_FOOT,   [3], 1);
    kill();

    alpha = 0.8;

    // 詳細テキスト
    _txtDetail = new FlxText();
    _txtDetail.setBorderStyle(FlxText.BORDER_OUTLINE);
    _txtDetail.text = "";
  }

  /**
   * アニメ再生
   * @param bReachable 到達可能かどうか
   * @param bFoot      踏破済みかどうか
   **/
  public function _playAnime(bReachable:Bool, bFoot:Bool):Void {

    var name:String = "";

    if(bReachable) {
      // 到達可能
      if(bFoot) {
        name = ANIME_REACHABLE_FOOT;
      }
      else {
        name = ANIME_REACHABLE_NOFOOT;
      }
    }
    else {
      // 到達不可
      if(bFoot) {
        name = ANIME_NONREACHABLE_FOOT;
      }
      else {
        name = ANIME_NONREACHABLE_NOFOOT;
      }
    }

    // アニメ再生
    animation.play(name);
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, evType:FieldEvent, eftType:FieldEffect) {
    x = X;
    y = Y;

    _txtDetail.x = x+8;
    _txtDetail.y = y-8;

    // イベント種別を設定する
    setEventType(evType);

    // 地形効果を設定する
    setEffectType(eftType);

    _bFoot    = false;
    reachable = false;
    _bOpened  = false;
    _reachableNodes = new List<FieldNode>();
  }

  /**
   * マウスが上に乗っているかどうか
   **/
  public function overlapsMouse():Bool {
    var dx = xcenter - FlxG.mouse.x;
    var dy = ycenter - FlxG.mouse.y;
    if(dx*dx + dy*dy < RADIUS*RADIUS) {
      // 乗っている
      return true;
    }

    // 乗っていない
    return false;
  }

  /**
   * 色を設定
   **/
  private function _setColor():Void {

    _txtDetail.text = "";

    var col:Int = FlxColor.WHITE;
    switch(_evType) {
      case FieldEvent.None:
        col = FlxColor.SILVER;
      case FieldEvent.Random:
        col = FlxColor.WHITE;
      case FieldEvent.Goal:
        col = FlxColor.CHARTREUSE;
        _txtDetail.text = "Next";
        _txtDetail.color = col;
      case FieldEvent.Enemy:
        col = FlxColor.SALMON;
      case FieldEvent.Item:
        col = FlxColor.GOLDENROD;
      case FieldEvent.Shop:
        col = FlxColor.AQUAMARINE;
        _txtDetail.text = "Shop";
        _txtDetail.color = col;
    }

    color = col;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _tAnim++;

    // 詳細テキスト更新
    {
      var deg = _tAnim % 180;
      _txtDetail.alpha = 0.3 + (0.7 * MyMath.sinEx(deg));
    }

    // 地形効果演出
    var col = FieldEffectUtil.toColor(eftType);
    switch(eftType) {
      case FieldEffect.None:
        // 何もしない
      case FieldEffect.Damage, FieldEffect.Poison:
        if(_tAnim%12 == 0) {
          var px = xcenter;
          var py = y + height;
          FieldParticle.start(FieldParticleType.Spiral, px, py, col);
        }
    }

  }
}

