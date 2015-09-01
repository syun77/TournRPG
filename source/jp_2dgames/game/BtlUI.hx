package jp_2dgames.game;
import jp_2dgames.lib.StatusBar;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * バトルUI
 **/
class BtlUI extends FlxSpriteGroup {

  var _playerID:Int = 0;
  var _enemyID:Int = 0;

  var _txtPlayerHp:FlxText;
  var _txtEnemyHp:FlxText;
  var _barPlayerHp:StatusBar;
  var _barEnemyHp:StatusBar;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // テスト用にボタン配置
    var px = 0;
    var py = FlxG.height-64;
    var btn = new MyButton(px, py, "ATTACK3", function() {
      trace("ATTACK");
      var player = Actor.get(_playerID);
      player.damage(10);
    });
    this.add(btn);
    px += 80;
    this.add(new MyButton(px, py, "ATTACK1", function() {
      btn.enabled = true;
    }));
    px += 80;
    this.add(new MyButton(px, py, "ATTACK2", function() {
      btn.enabled = false;
    }));

    _txtPlayerHp = new FlxText(0, 0);
    _barPlayerHp = new StatusBar(0, 24);
    _txtEnemyHp = new FlxText(0, 48);
    _barEnemyHp = new StatusBar(0, 64);
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

    var player = Actor.get(_playerID);
    if(player != null) {
      var hp = player.hp;
      var hpmax = player.hpmax;
      _txtPlayerHp.text = 'Player HP: ${hp}/${hpmax}';
      _barPlayerHp.setPercent(100 * player.hpratio);
    }

    var enemy = Actor.get(_enemyID);
    if(enemy != null) {
      var hp = enemy.hp;
      var hpmax = enemy.hpmax;
      _txtEnemyHp.text = 'Enemy HP: ${hp}/${hpmax}';
      _barEnemyHp.setPercent(100 * enemy.hpratio);
    }
  }
}
