package jp_2dgames.game.gui;
import jp_2dgames.game.MyColor;
import jp_2dgames.game.MyColor;
import flixel.util.FlxColor;
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
class InventroyUI extends FlxSpriteGroup {

  // ■定数
  public static inline var CMD_CANCEL:Int = -1;

  // 座標
  private static inline var BASE_X = 0;
  private static inline var BASE_OFS_Y = -80;

  // ボタン
  private static inline var BTN_X = 0;
  private static inline var BTN_Y = 0;
  private static inline var BTN_DX = 80;
  private static inline var BTN_DY = 24;

  // ページ情報
  private static inline var PAGE_DISP_NUM:Int = 8;

  // ■メンバ変数
  private var _btnList:Array<MyButton>;
  // ページ番号
  private var _nPage:Int = 0;

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

    // ボタンの表示
    _displayButton(cbFunc, actor);
  }

  /**
   * ボタンの表示
   **/
  private function _displayButton(cbFunc:Int->Void, actor:Actor):Void {
    // コマンドボタンの配置
    _btnList = new Array<MyButton>();

    var ofs   = _getPageOffset();
    var max   = _getPageOffsetMax();

    for(idx in ofs...max) {

      var item = Inventory.getItem(idx);
      // 座標
      var px = BTN_X + BTN_DX * (idx%3);
      var py = BTN_Y + BTN_DY * Math.floor(idx/3);
      // アイテム名
      var name = ItemUtil.getName(item);
      var btnID = idx;
      var btn = new MyButton(px, py, name, function() {
        if(ItemUtil.isEquip(item.id)) {
          // 装備品
          _toggleEquip(btnID, actor);
        }
        else {
          // 消耗品
          cbFunc(btnID);
        }
      });
      _btnList.push(btn);

    }

    // キャンセルボタン
    var px = BTN_X + BTN_DX*2;
    var py = BTN_Y + BTN_DY*2;
    _btnList.push(new MyButton(px, py, "CANCEL", function() {
      cbFunc(CMD_CANCEL);
    }));

    for(btn in _btnList) {
      this.add(btn);
    }

    // ボタン色を更新
    _updateButtonColor();

    // 出現アニメーション
    {
      var py2 = y;
      y = FlxG.height;
      FlxTween.tween(this, {y:py2}, 0.5, {ease:FlxEase.expoOut});
    }
  }

  /**
   * アイテム装備の切り替え
   **/
  private function _toggleEquip(idx:Int, actor):Void {
    Inventory.equip(idx);

    // ボタン色を更新
    _updateButtonColor();
  }

  /**
   * ボタンの色を更新
   **/
  private function _updateButtonColor():Void {
    // 装備しているアイテムのボタンの色を変える
    var ofs   = _getPageOffset();
    var max   = _getPageOffsetMax();

    for(idx in ofs...max) {
      var item = Inventory.getItem(idx);
      if(ItemUtil.isEquip(item.id) == false) {
        // 装備アイテムでない
        continue;
      }

      // ボタンを取得
      var btnIdx = idx - ofs;
      var btn = _btnList[btnIdx];
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
}
