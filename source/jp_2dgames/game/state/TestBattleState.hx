package jp_2dgames.game.state;

import flixel.FlxG;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.lib.Input;
import flixel.text.FlxText;
import flixel.FlxState;

/**
 * バトルテスト画面
 **/
class TestBattleState extends FlxState {

  // 敵グループ番号
  var _nEnemyGroup:Int = 1;

  var _txtBattle:FlxText;
  var _txtExit:FlxText;
  var _txtEnemyList:Array<FlxText>;

  var _csvGroup:CsvLoader;
  var _csvEnemy:CsvLoader;

  var _min:Int = 1;
  var _max:Int = 1;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // デバッグ用バトル
    Global.setTestBattle(true);

    _csvEnemy = new CsvLoader(Reg.PATH_CSV_ENEMY);
    _csvGroup = new CsvLoader(Reg.PATH_CSV_ENEMY_GROUP);

    var px = 16;
    var py = 48;
    var dy = 16;
    _txtBattle = new FlxText(px, py, "Battle");
    py += dy;
    _txtExit   = new FlxText(px, py, "X to Exit");

    this.add(_txtBattle);
    this.add(_txtExit);

    _txtEnemyList = new Array<FlxText>();
    py += dy*2;
    for(i in 0...5) {
      var txt = new FlxText(px, py);
      txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
      _txtEnemyList.push(txt);
      this.add(txt);
      py += dy;
    }

    // 敵グループの最大値を検索
    _csvGroup.foreach(function(data:Map<String, String>) {
      var id = Std.parseInt(data["id"]);
      if(id >_max) {
        // 最大値更新
        _max = id;
      }
    });

    // 敵の名前を更新
    _updateEnemyname();
  }

  /**
   * 破棄
   */
  override public function destroy():Void {
    super.destroy();

    // テストバトル終了
    Global.setTestBattle(false);
  }

  /**
   * 敵の名前を更新
   **/
  private function _updateEnemyname():Void {

    for(i in 0...5) {
      var id = _csvGroup.getInt(_nEnemyGroup, 'enemy0${i+1}');
      var name = _csvEnemy.searchItem("id", '${id}', "name", false);
      name = '${i+1}: ' + name;
      if(id == 0) {
        name = "";
      }
      _txtEnemyList[i].text = name;
    }
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();

    _txtBattle.text = 'Battle: ${_nEnemyGroup} / ${_max}';

    var bChange:Bool = false;
    if(Input.press.LEFT) {
      _nEnemyGroup--;
      bChange = true;
      if(_nEnemyGroup < _min) {
        _nEnemyGroup = _max;
      }
    }
    if(Input.press.RIGHT) {
      _nEnemyGroup++;
      bChange = true;
      if(_nEnemyGroup > _max) {
        _nEnemyGroup = _min;
      }
    }

    if(bChange) {
      // 敵の名前を更新
      _updateEnemyname();
    }

    if(Input.press.A) {
      // バトル開始
      Global.setEnemyGroup(_nEnemyGroup);
      openSubState(new BattleState());
    }
    else if(Input.press.B) {
      FlxG.switchState(new FieldState());
    }

    #if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
    #end
  }
}
