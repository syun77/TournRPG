package jp_2dgames.game.gui;
import jp_2dgames.game.actor.ActorMgr;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import jp_2dgames.lib.StatusBar;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * バトルUI
 **/
class BtlUI extends FlxSpriteGroup {

  // ■定数
  static inline var PLAYER_X:Int = 4;
  static inline var PLAYER_Y:Int = 4;
  static inline var PLAYER_DY:Int = 12;

  // ■メンバ変数
  var _playerID:Int = 0;

  var _txtStage:FlxText;
  var _txtPlayerLv:FlxText;
  var _txtPlayerXp:FlxText;
  var _txtPlayerMoney:FlxText;
  var _txtPlayerHp:FlxText;
  var _barPlayerHp:StatusBar;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    var txtList = new List<FlxText>();
    var px = PLAYER_X;
    var py = PLAYER_Y;
    _txtStage = new FlxText(px, py);
    txtList.add(_txtStage);
    py += PLAYER_DY;
    _txtPlayerLv = new FlxText(px, py);
    txtList.add(_txtPlayerLv);
    py += PLAYER_DY;
    _txtPlayerXp = new FlxText(px, py);
    txtList.add(_txtPlayerXp);
    py += PLAYER_DY;
    _txtPlayerMoney = new FlxText(px, py);
    txtList.add(_txtPlayerMoney);
    py += PLAYER_DY;
    _txtPlayerHp = new FlxText(px, py);
    txtList.add(_txtPlayerHp);
    py += PLAYER_DY;

    _barPlayerHp = new StatusBar(px, py);
    this.add(_barPlayerHp);
    py += PLAYER_DY;

    for(txt in txtList) {
      this.add(txt);
      txt.setBorderStyle(FlxText.BORDER_OUTLINE);
    }

    for(obj in members) {
      obj.scrollFactor.set(0, 0);
    }

    for(i in 0...3) {
      var px = FlxG.width/3 * i;
      this.add(new BtlCharaUI(px, 4));
    }
  }

  public function setPlayerID(id:Int) {
    _playerID = id;
  }

  override public function update():Void {
    super.update();

    // プレイヤー情報
    var player = ActorMgr.search(_playerID);
    if(player != null) {
      var hp = player.hp;
      var hpmax = player.hpmax;
      _txtStage.text       = 'Stage: ${Global.getStage()}';
      _txtPlayerLv.text    = 'LV: ${player.lv}';
      _txtPlayerXp.text    = 'Exp: ${player.xp}';
      _txtPlayerMoney.text = 'MONEY: ${Global.getMoney()}';
      _txtPlayerHp.text    = 'HP: ${hp}/${hpmax}';
      _barPlayerHp.setPercent(100 * player.hpratio);
    }
  }
}
