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
  var _enemyID:Int = 0;

  var _txtPlayerLv:FlxText;
  var _txtPlayerXp:FlxText;
  var _txtPlayerMoney:FlxText;
  var _txtPlayerHp:FlxText;
  var _txtEnemyHp:FlxText;
  var _barPlayerHp:StatusBar;
  var _barEnemyHp:StatusBar;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    var bg = new FlxSprite().makeGraphic(FlxG.width, 104, FlxColor.BLACK);
    bg.alpha = 0.6;
    this.add(bg);

    var px = PLAYER_X;
    var py = PLAYER_Y;
    _txtPlayerLv = new FlxText(px, py);
    py += PLAYER_DY;
    _txtPlayerXp = new FlxText(px, py);
    py += PLAYER_DY;
    _txtPlayerMoney = new FlxText(px, py);
    py += PLAYER_DY;
    _txtPlayerHp = new FlxText(px, py);
    py += PLAYER_DY;
    _barPlayerHp = new StatusBar(px, py);
    py += PLAYER_DY;
    _txtEnemyHp = new FlxText(px, py);
    py += PLAYER_DY;
    _barEnemyHp = new StatusBar(px, py);
    this.add(_txtPlayerLv);
    this.add(_txtPlayerXp);
    this.add(_txtPlayerMoney);
    this.add(_txtPlayerHp);
    this.add(_barPlayerHp);
    this.add(_txtEnemyHp);
    this.add(_barEnemyHp);

  }

  public function setPlayerID(id:Int) {
    _playerID = id;
  }
  public function setEnemyID(id:Int) {
    _enemyID = id;
  }

  override public function update():Void {
    super.update();

    // プレイヤー情報
    var player = ActorMgr.search(_playerID);
    if(player != null) {
      var hp = player.hp;
      var hpmax = player.hpmax;
      _txtPlayerLv.text = 'LV: ${player.lv}';
      _txtPlayerXp.text = 'Exp: ${player.xp}';
      _txtPlayerMoney.text = 'MONEY: ${Global.getMoney()}';
      _txtPlayerHp.text = 'HP: ${hp}/${hpmax}';
      _barPlayerHp.setPercent(100 * player.hpratio);
    }

    // 敵情報
    var enemy = ActorMgr.search(_enemyID);
    if(enemy != null) {
      var hp = enemy.hp;
      var hpmax = enemy.hpmax;
      _txtEnemyHp.text = 'Enemy HP: ${hp}/${hpmax}';
      _barEnemyHp.setPercent(100 * enemy.hpratio);
    }
  }
}
