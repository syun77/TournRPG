package jp_2dgames.game.gui;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import jp_2dgames.game.MyColor;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.Inventory;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * インベントリUI
 **/
class InventoryUI extends FlxSpriteGroup {

  // ■定数
  public static inline var CMD_CANCEL:Int = -1;

  // 起動モード
  public static inline var MODE_NORMAL:Int = 0; // 通常
  public static inline var MODE_DROP:Int   = 1; // 捨てる

  // 座標
  private static inline var BASE_X = 0;
  private static inline var BASE_OFS_Y = -(BTN_DY*3.5)-BTN_Y;

  // ボタン
  private static inline var BTN_X = 0;
  private static inline var BTN_Y = BTN_PAGE_Y + 48;
  private static inline var BTN_DX = MyButton.WIDTH;
  private static inline var BTN_DY = MyButton.HEIGHT + 2;

  // ページ切り替えボタン
  private static inline var BTN_PREV_X = 0;
  private static inline var BTN_NEXT_X = MyButton.WIDTH;
  private static inline var BTN_PAGE_Y = 24;

  // ページ情報
  private static inline var PAGE_DISP_NUM:Int = 8;
  private static inline var PAGE_X = BTN_PREV_X + 4;
  private static inline var PAGE_Y = 0;

  // ボタン番号
  private static inline var BTN_ID_CANCEL:Int = -1;
  private static inline var BTN_ID_PAGE:Int = -2;

  // ■スタティック
  private static var _instance:InventoryUI = null;

  // 開く
  public static function open(cbFunc:Int->Void, actor:Actor):Void {
    if(_instance == null) {
      _instance = new InventoryUI(cbFunc, actor);
      FlxG.state.add(_instance);
    }
  }

  // ■メンバ変数
  // モード
  private var _mode:Int;
  private var _btnList:Array<MyButton>;
  // ページ番号
  private var _nPage:Int = 0;
  // ページの最大数
  private var _nPageMax:Int = 0;
  // ページテキスト
  private var _txtPage:FlxText;

  // 装備品UI
  private var _equipUI:EquipUI;

  // アイテム詳細UI
  private var _detailUI:DetailUI;

  // 表示アニメーション
  private var _tween:FlxTween = null;

  /**
   * コンストラクタ
   * @param cbFunc アイテム選択コールバック
   * @param actor  行動主体者
   **/
  public function new(cbFunc:Int->Void, actor:Actor) {

    // 基準座標を設定
    {
      var px = BASE_X;
      var py = FlxG.height + BASE_OFS_Y;
      super(px, py);
    }

    // モード判定
    _mode = MODE_NORMAL;
    if(actor == null) {
      // 捨てるモード
      _mode = MODE_DROP;
    }

    // 最大ページ数
    _nPageMax = Math.ceil(Inventory.lengthItemList()/PAGE_DISP_NUM);

    // ページテキスト
    _txtPage = new FlxText(PAGE_X, PAGE_Y, 128, "", 12);
    this.add(_txtPage);

    // ボタンの表示
    _displayButton(cbFunc, actor);

    // 装備情報
    _equipUI = new EquipUI();
    if(_mode == MODE_NORMAL) {
      FlxG.state.add(_equipUI);
    }

    // アイテム詳細
    _detailUI = new DetailUI();
    FlxG.state.add(_detailUI);
    // 非表示にしておく
    _detailUI.visible = false;
  }

  /**
   * 消滅
   **/
  override public function kill():Void {

    // アイテム詳細UIを消す
    FlxG.state.remove(_detailUI);
    // 装備UIを消す
    FlxG.state.remove(_equipUI);
    super.kill();
  }


  /**
   * ボタンの表示
   **/
  private function _displayButton(cbFunc:Int->Void, actor:Actor):Void {

    // ページ数表示を更新しておく
    _txtPage.text = 'Page: (${_nPage+1}/${_nPageMax})';

    // コマンドボタンの配置
    _btnList = new Array<MyButton>();

    var ofs = _getPageOffset();
    var max = _getPageOffsetMax();

    for(idx in ofs...max) {

      var item = Inventory.getItem(idx);
      var idx2 = idx - ofs;
      // 座標
      var px = BTN_X + BTN_DX * (idx2%3);
      var py = BTN_Y + BTN_DY * Math.floor(idx2/3);
      // アイテム名
      var name = ItemUtil.getName(item);
      var btnID = idx;
      var btn = new MyButton(px, py, name, function() {

        // ボタンを押した
        switch(_mode) {
          case MODE_NORMAL:
            if(ItemUtil.isEquip(item.id)) {
              // 装備品
              _toggleEquip(btnID, actor);
            }
            else {
              // 消耗品
              cbFunc(btnID);
              // UIを閉じる
              _close();
            }
          case MODE_DROP:
            // 捨てる
            cbFunc(btnID);
            // UIを閉じる
            _close();
        }
      });
      // 要素番号を入れておく
      btn.ID = idx2;
      _btnList.push(btn);

    }

    // キャンセルボタン
    {
      var px = BTN_X + BTN_DX*2;
      var py = BTN_Y + BTN_DY*2;
      var btn = new MyButton(px, py, "CANCEL", function() {
        cbFunc(CMD_CANCEL);
        // UIを閉じる
        _close();
      });
      btn.ID = BTN_ID_CANCEL;
      btn.color       = MyColor.BTN_CANCEL;
      btn.label.color = MyColor.BTN_CANCEL_LABEL;
      _btnList.push(btn);
    }

    // ページ切り替えボタン
    {
      // 1つ前に戻る
      var py = BTN_PAGE_Y;
      var btn = new MyButton(BTN_PREV_X, py, "<<", function() {
        _changePage(-1, cbFunc, actor);
      });
      btn.enable = (_nPage > 0);
      btn.ID = BTN_ID_PAGE;
      _btnList.push(btn);
    }
    {
      // 1つ先に進む
      var py = BTN_PAGE_Y;
      var btn = new MyButton(BTN_NEXT_X, py, ">>", function() {
        _changePage(1, cbFunc, actor);
      });
      btn.enable = (_nPage < _nPageMax - 1);
      btn.ID = BTN_ID_PAGE;
      _btnList.push(btn);
    }

    for(btn in _btnList) {
      this.add(btn);
    }

    // ボタン色を更新
    _updateButtonColor();

    // 出現アニメーション
    if(_tween != null) {
      _tween.cancel();
    }
    {
      var py2 = FlxG.height + BASE_OFS_Y;
      y = FlxG.height;
      _tween = FlxTween.tween(this, {y:py2}, 0.5, {ease:FlxEase.expoOut});
    }
  }

  /**
   * ページ切り替え
   **/
  private function _changePage(ofs:Int, cbFunc:Int->Void, actor:Actor):Void {
    _nPage += ofs;
    if(_nPage < 0) {
      _nPage = _nPageMax - 1;
    }
    else if(_nPage >= _nPageMax) {
      _nPage = 0;
    }

    // ボタンをすべて消す
    for(btn in _btnList) {
      this.remove(btn);
    }

    // ボタンを再表示
    _displayButton(cbFunc, actor);
  }

  /**
   * アイテム装備の切り替え
   **/
  private function _toggleEquip(idx:Int, actor):Void {
    Inventory.equip(idx);

    // ボタン色を更新
    _updateButtonColor();

    // 装備UIを更新
    _equipUI.setText();
  }

  /**
   * ボタンの色を更新
   **/
  private function _updateButtonColor():Void {

    // 装備しているアイテムのボタンの色を変える
    var ofs = _getPageOffset();
    var max = _getPageOffsetMax();

    for(idx in ofs...max) {
      var item = Inventory.getItem(idx);

      // ボタンを取得
      var btnIdx = idx - ofs;
      var btn = _btnList[btnIdx];

      if(ItemUtil.isConsumable(item.id)) {
        // 消費アイテム
        btn.color       = MyColor.BTN_CONSUME;
        btn.label.color = MyColor.BTN_CONSUME_LABEL;
        continue;
      }

      // 装備アイテム
      if(item.isEquip == false) {
        // 装備していない
        // デフォルト色に戻す
        btn.setDefaultColor();
        continue;
      }

      // 装備している
      btn.color       = MyColor.BTN_EQUIP;
      btn.label.color = MyColor.BTN_EQUIP_LABEL;
    }
  }

  /**
   * ページ開始オフセットを取得する
   **/
  private function _getPageOffset():Int {
    return _nPage * PAGE_DISP_NUM;
  }

  /**
   * ページ終端のオフセットを取得する
   **/
  private function _getPageOffsetMax():Int {
    var count = Inventory.lengthItemList();
    var ofs   = _getPageOffset();
    var max   = ofs + PAGE_DISP_NUM;
    if(max > count) {
      // アイテム所持数を超えないようにする
      max = count;
    }

    return max;
  }

  override public function update():Void {
    super.update();

    // ボタンの状態を調べる
    for(btn in _btnList) {
      switch(btn.status) {
        case FlxButton.HIGHLIGHT, FlxButton.PRESSED:
          _detailUI.visible = true;
          var idx = btn.ID;
          if(idx < 0) {
            continue;
          }

          idx += _getPageOffset();
          // 表示情報を更新
          var item = Inventory.getItem(idx);
          _detailUI.setText(item);
          return;
      }
    }

    // ボタンを選択していないので非表示
    _detailUI.visible = false;
  }

  /**
   * UIを閉じる
   **/
  private function _close():Void {
    kill();
    FlxG.state.remove(this);
    _instance = null;
  }
}
