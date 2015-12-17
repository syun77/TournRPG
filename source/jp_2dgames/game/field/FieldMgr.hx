package jp_2dgames.game.field;

import jp_2dgames.game.field.FieldEffectUtil.FieldEffect;
import jp_2dgames.lib.Snd;
import flixel.FlxObject;
import flixel.FlxCamera;
import jp_2dgames.game.gui.MyButton2;
import jp_2dgames.game.gui.FieldUI;
import jp_2dgames.game.state.ShopState;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import jp_2dgames.game.gui.BtlPlayerUI;
import jp_2dgames.game.gui.BtlCharaUI;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.Actor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxPoint;
import jp_2dgames.game.gui.InventoryUI;
import jp_2dgames.game.gui.UIMsg;
import jp_2dgames.game.util.LineMgr;
import jp_2dgames.game.state.FieldSubState;
import jp_2dgames.game.state.FieldState;
import jp_2dgames.lib.CsvLoader;

/**
 * 状態
 **/
private enum State {
  Main;        // メイン
  Moving;      // 移動中

  HungerBegin; // 空腹ダメージ開始
  HungerExec;  // 空腹ダメージ実行中

  EventBegin;  // イベント開始
  EventExec;   // イベント実行中
  EventResult; // イベント実行結果

  Shop;        // ショップ表示中
  NextFloor;   // 次のフロアに進む

  Gameover;  // ゲームオーバー
  End;       // 終了
}

/**
 * フィールド管理
 **/
class FieldMgr {

  // 戻り値
  public static inline var RET_NONE:Int      = 0;
  public static inline var RET_NEXTSTAGE:Int = 1;
  public static inline var RET_GAMEOVER:Int  = 2;

  // 点線の最大数
  static inline var LINE_MAX:Int = 8;

  // 状態
  var _state:State = State.Main;

  // 親
  var _flxState:FieldState;

  // 現在いるノード
  var _nowNode:FieldNode;

  // 経路描画
  var _lines:LineMgr;

  // プレイヤートークン
  var _player:FieldPlayer;

  // イベント管理
  var _eventMgr:FieldEventMgr;

  // メニューボタン
  var _btnMenu:MyButton2;

  // 次のフロアに進むボタン
  var _btnNextFloor:MyButton2;

  // ショップボタン
  var _btnShop:MyButton2;

  // Actor情報
  var _actor:Actor;

  // キャラUI
  var _charaUI:BtlCharaUI;

  // フィールドUI
  var _fieldUI:FieldUI;

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

    FlxG.watch.add(this, "_state");

    // 背景
    var bg = new FlxSprite().loadGraphic(Reg.getBackImagePath(1));
    bg.color = FlxColor.SILVER;
    bg.scale.set(1.5, 1.5);
    _flxState.add(bg);
    var bgPath = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
    _flxState.add(bgPath);

    // ノード管理作成
    FieldNode.createParent(_flxState);

    // F.O.E.
    FieldFoe.createParent(_flxState);

    // マップの作成
    if(Global.isLoad()) {
      // ロードしたデータを使う

      // ノードをロード
      TmpFieldNode.copyToFieldNode();
      TmpFieldNode.destroy();
      _nowNode = FieldNode.getStartNode();

      // F.O.E.をロード
      TmpFieldFoe.copyToFieldFoe();
      TmpFieldFoe.destroy();

      // ロード終了
      Global.setLoadFlag(false);
    }
    else {
      // 新規作成
      _nowNode = FieldNodeUtil.create();
      // 開始地点を踏破済みにしておく
      _nowNode.setFoot(true);

      // TODO: F.O.E.をひとまず出してみる
      {
        var node = FieldNode.random(FieldEvent.None);
        if(node != null) {
          FieldFoe.add(node.ID, 6);
          // TODO: 毒ゾーンを仮設定
          node.setEffectType(FieldEffect.Poison);

        }
      }

      // TODO: ショップをひとまず配置
      #if !debug
      {
        var node = FieldNode.random(FieldEvent.None);
        if(node != null) {
          node.setEventType(FieldEvent.Shop);
        }

        // ショップ情報の初期化
        Global.getShopData().testdata();
      }
      #else
      // TODO: ショップを全配置
      while(true)
      {
        var node = FieldNode.random(FieldEvent.None);
        if(node == null) {
          break;
        }
        node.setEventType(FieldEvent.Shop);

        // ショップ情報の初期化
        Global.getShopData().testdata();
      }
      #end
    }

    // 経路描画
    _createWayLine(bgPath);


    // プレイヤー
    _player = new FieldPlayer();
    _flxState.add(_player);

    // Actor情報を生成
    _actor = new Actor(0);
    _actor.init(BtlGroup.Player, Global.getPlayerParam());
    _actor.setName(Global.getPlayerName());

    // 移動可能な経路を表示
    _lines = new LineMgr(_flxState, LINE_MAX, MyColor.ASE_LIME);
    _openNodes();

    // イベント管理
    _eventMgr = new FieldEventMgr(_flxState, _actor);

    // UI表示
    _charaUI = new BtlCharaUI(0, BtlPlayerUI.CHARA_Y, _actor);
    _charaUI.scrollFactor.set();
    _flxState.add(_charaUI);

    // フィールドUI
    _fieldUI = new FieldUI(_actor);
    _fieldUI.scrollFactor.set();
    _flxState.add(_fieldUI);

    // メッセージ
    var csv = new CsvLoader(Reg.PATH_CSV_MESSAGE);
    Message.createInstance(csv, _flxState);

    // サブメニュー呼び出しボタン
    {
      var label = UIMsg.get(UIMsg.MENU);
      var px = InventoryUI.BTN_CANCEL_X;
      _btnMenu = new MyButton2(px, 0, label, function() {
        _hideUI();
        // プレイヤーフォーカス
        FlxG.camera.follow(_player, FlxCamera.STYLE_LOCKON, null, 10);
        _flxState.openSubState(new FieldSubState(_actor, _charaUI, function() {
          // サブメニューを閉じたときに呼び出す関数
          _appearUI();
          var obj = new FlxObject(FlxG.width/2, FlxG.height/2);
          FlxG.camera.follow(obj, FlxCamera.STYLE_LOCKON, null, 10);
        }));
      });
      flxState.add(_btnMenu);
    }

    // 次のフロアに進むボタン
    {
      var label = UIMsg.get(UIMsg.NEXT_FLOOR);
      var px = InventoryUI.BTN_NEXTFLOOR_X;
      _btnNextFloor = new MyButton2(px, 0, label, function() {
        _hideUI();
        // 次のフロアに進む
        _gotoNextFloor();
      });
      _btnNextFloor.color = MyColor.BTN_SHOP;
      _btnNextFloor.label.color = MyColor.BTN_SHOP_LABEL;
      flxState.add(_btnNextFloor);
    }

    // パーティクル管理生成
    FieldParticle.create(_flxState);

    // ショップボタン
    {
      var label = UIMsg.get(UIMsg.SHOP);
      var px = InventoryUI.BTN_SHOP_X;
      _btnShop = new MyButton2(px, 0, label, function() {
        _hideUI();
        // プレイヤーフォーカス
        FlxG.camera.follow(_player, FlxCamera.STYLE_LOCKON, null, 10);
        // ショップを表示
        _flxState.openSubState(new ShopState(_cbShopEnd, _fieldUI, _charaUI, _actor));
        _state = State.Shop;
      });
      _btnShop.color = MyColor.BTN_SHOP;
      _btnShop.label.color = MyColor.BTN_SHOP_LABEL;
      flxState.add(_btnShop);
    }

    // UI出現
    _appearUI();

    // ズーム演出
    _startZoom();
  }

  /**
   * ズーム演出開始
   **/
  private function _startZoom():Void {
    FlxG.camera.zoom = FlxCamera.defaultZoom + 0.3;
  }

  /**
   * 経路の線を生成する
   **/
  private function _createWayLine(bg:FlxSprite):Void {

    var ls:LineStyle = {color:0x40FFFFFF, thickness:0};
    FieldNodeUtil.drawReachableWay(function(n1:FieldNode, n2:FieldNode) {
      FlxSpriteUtil.drawLine(bg, n1.xcenter, n1.ycenter, n2.xcenter, n2.ycenter, ls);
    });
  }

  /**
   * UI非表示
   **/
  private function _hideUI():Void {
    _btnMenu.visible      = false;
    _btnNextFloor.visible = false;
    _btnShop.visible      = false;
    return;

    FieldNode.setVisible(false);
    _lines.visible = false;
  }

  /**
   * UI出現
   **/
  private function _appearUI():Void {

    // キャラUI
    {
      var py = BtlPlayerUI.CHARA_Y;
      _charaUI.y = -48;
      FlxTween.tween(_charaUI, {y:py}, 0.5, {ease:FlxEase.expoOut});
    }

    // サブメニューボタン
    {
      var py = InventoryUI.BTN_CANCEL_Y + InventoryUI.BASE_OFS_Y + FlxG.height;
      _btnMenu.y = FlxG.height;
      _btnMenu.visible = true;
      FlxTween.tween(_btnMenu, {y:py}, 0.5, {ease:FlxEase.expoOut});
    }

    // 次のフロアに進むボタン
    _appearUINextFloor();

    // ショップボタン
    _appearUIShop();

    FieldNode.setVisible(true);
    _lines.visible = true;
  }

  /**
   * 次のフロアへ進むUIを表示する
   **/
  private function _appearUINextFloor():Void {
    var py = InventoryUI.BTN_CANCEL_Y + InventoryUI.BASE_OFS_Y + FlxG.height;
    _btnNextFloor.y = FlxG.height;
    FlxTween.tween(_btnNextFloor, {y:py}, 0.5, {ease:FlxEase.expoOut});

    // ゴールにいるときだけ表示
    _btnNextFloor.visible = _nowNode.isGoal();
  }

  /**
   * ショップUIを表示する
   **/
  private function _appearUIShop():Void {
    var py = InventoryUI.BTN_CANCEL_Y + InventoryUI.BASE_OFS_Y + FlxG.height;
    _btnShop.y = FlxG.height;
    FlxTween.tween(_btnShop, {y:py}, 0.5, {ease:FlxEase.expoOut});

    // ショップにいるときだけ表示
    _btnShop.visible = _nowNode.isShop();
  }

  /**
   * 更新
   **/
  public function proc():Void {

    // ズーム演出
    {
      var d = FlxG.camera.zoom - FlxCamera.defaultZoom;
      FlxG.camera.zoom -= d * 0.1;
    }

    switch(_state) {
      case State.Main:
        _updateMain();

      case State.Moving:
        _updateMoving();

      case State.HungerBegin:
        _updateHungerBegin();

      case State.HungerExec:

      case State.EventBegin:
        _updateEventBegin();

      case State.EventExec:
        _updateEventExec();

      case State.EventResult:
        _updateEventResult();

      case State.Shop:

      case State.NextFloor:

      case State.Gameover:
        // グローバルに保存
        Global.setPlayerParam(_actor.param);
        // おしまい
        _state = State.End;

      case State.End:
        // おしまい
    }

    // メニューボタンの更新
    switch(_state) {
      case State.Main:
        _btnMenu.enabled = true;
      default:
        _btnMenu.enabled = false;
        _btnNextFloor.visible = false;
        _btnShop.visible = false;
    }
  }

  static var count:Int = 1;

  /**
   * 更新・メイン
   **/
  private function _updateMain():Void {

    // プレイヤーの位置を設定
    _player.setPositionFromNode(_nowNode);

    var selNode:FieldNode = null;
    FieldNode.forEachAlive(function(node:FieldNode) {
      node.scale.set(1, 1);

      #if mobile
      if(FlxG.mouse.pressed == false) {
        // タップしていない場合は判定不要
        return;
      }
      #end

      if(node.reachable == false) {
        // 移動できないところは選べない
        return;
      }
      if(node.isStartFlag()) {
        // スタート地点は選べない
        return;
      }

      if(node.overlapsMouse()) {
        // 選択した
        selNode = node;
      }
    });


    if(selNode == null) {
      return;
    }

    // 選択しているノードがある
    selNode.scale.set(1.5, 1.5);

    if(FlxG.mouse.justPressed) {

      // 移動先を選択した
      Snd.playSe("menu");
      // 元のノードは何もない状態にする
      _nowNode.setEventType(FieldEvent.None);

      selNode.scale.set(1, 1);

      // 経路をいったん消す
      _lines.kill();

      // 選択したノードに向かって移動する
      _state = State.Moving;
      _player.moveTowardNode(selNode, function() {

        // 踏破した
        _nowNode.setFoot(true);

        // 空腹チェック
        _state = State.HungerBegin;

        _nowNode = selNode;
        return;


      });
    }
  }

  /**
   * 更新・移動中
   **/
  private function _updateMoving():Void {
  }

  /**
   * 空腹ダメージ
   * @return 死亡したらtrue
   **/
  private function _damageHunger():Bool {
    var v = Std.int(_actor.hpmax * Reg.FOOD_DAMAGE);
    Message.push2(Msg.DAMAGE_PLAYER, [_actor.name, v]);
    _charaUI.damage();
    _charaUI.shake();

    // SE再生
    Snd.playSe("hit");

    // ダメージを与える
    return _actor.damage(v);
  }

  /**
   * 更新・イベント開始
   **/
  private function _updateEventBegin():Void {
    // F.O.E.との接触チェック
    var foe = FieldFoe.searchFromNodeID(_nowNode.ID);
    if(foe != null) {
      // F.O.E.とのバトル開始
      _eventMgr.startBattle(_nowNode, foe);
    }
    else {
      _eventMgr.start(_nowNode);
    }
    // 開始ノードに設定
    FieldNode.setStartNode(_nowNode);

    // イベント実行
    _state = State.EventExec;
  }

  /**
   * 更新・イベント
   **/
  private function _updateEventExec():Void {
    _eventMgr.proc();
    if(_eventMgr.isEnd() == false) {
      return;
    }

    // イベント処理へ
    _state = State.EventResult;
  }

  /**
   * 更新・空腹ダメージ
   **/
  private function _updateHungerBegin():Void {
    // 食糧を減らす
    if(_actor.param.food > 0) {
      _actor.param.food--;
      // イベント処理へ
      _state = State.EventBegin;
      return;
    }

    // 空腹ダメージ実行
    _state = State.HungerExec;
    // 食糧がないのでダメージ (20%)
    _damageHunger();
    if(_actor.isDead()) {
      // 死亡したので赤フラッシュ
      FlxG.camera.flash(FlxColor.RED, 0.2);
      // プレイヤーアイコンを消しておく
      _player.visible = false;
    }
    // 揺らす
    FlxG.camera.shake(0.01, 0.5, function() {
      if(_actor.isDead()) {
        // 餓死
        Message.push2(Msg.DEAD, [_actor.name]);
        var px = FlxG.width/2 - MyButton2.WIDTH/2;
        var py = FlxG.height -128;
        var btn = new MyButton2(px, py, "NEXT", function() {
          // ゲームオーバー
          _resultCode = RET_GAMEOVER;
          _state = State.Gameover;
        });
        _flxState.add(btn);
      }
      else {
        // 死亡していないのでイベント処理へ
        _state = State.EventBegin;
      }
    });
  }

  /**
   * 更新・イベント実行結果
   **/
  private function _updateEventResult():Void {
    switch(_eventMgr.resultCode) {
      case FieldEventMgr.RET_NONE:
        // 探索を続ける

        // 移動可能なノードを開く
        _openNodes();

        if(_eventMgr.isBtlEnd()) {
          // UI表示
          _appearUI();
          // ズーム演出開始
          _startZoom();
        }

        // メイン処理に戻る
        _state = State.Main;

      case FieldEventMgr.RET_GAMEOVER:
        // ゲームオーバー
        _resultCode = RET_GAMEOVER;
        _state = State.Gameover;

      case FieldEventMgr.RET_GOAL:
        // ゴール
        _openNodes();
        // 次のフロアに進むボタンを表示
        _appearUINextFloor();
        // メイン処理に戻る
        _state = State.Main;

      case FieldEventMgr.RET_SHOP:
        // ショップ
        _openNodes();
        // ショップボタンを表示
        _appearUIShop();
        // メイン処理に戻る
        _state = State.Main;
    }
  }

  /**
   * ショップ終了時に呼び出す関数
   **/
  private function _cbShopEnd():Void {
    // ショップ終わり
    _state = State.Main;

    // フォーカスを戻す
    var obj = new FlxObject(FlxG.width/2, FlxG.height/2);
    FlxG.camera.follow(obj, FlxCamera.STYLE_LOCKON, null, 10);

    // UI表示
    _appearUI();
  }

  /**
   * ノードを開く
   **/
  private function _openNodes():Void {
    // すべてを移動不可にする
    FieldNode.forEachAlive(function(n:FieldNode) {
      n.reachable = false;
    });
    _nowNode.openNodes();

    // 経路描画
    // いったん非表示
    _lines.kill();
    for(n in _nowNode.reachableNodes) {
      _lines.drawFromNode(_nowNode, n);
    }
  }

  /**
   * 次のフロアに進む
   **/
  private function _gotoNextFloor():Void {
    // 次のステージに進む
    _state = State.NextFloor;
    Snd.playSe("foot2");
    // フェード開始
    FlxG.camera.fade(FlxColor.BLACK, 1, false, function() {
      // グローバルに保存
      Global.setPlayerParam(_actor.param);
      _resultCode = RET_NEXTSTAGE;
      _state = State.End;
    });
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }
}
