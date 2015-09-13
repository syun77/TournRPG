package jp_2dgames.game.btl;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.ActorMgr;
import flixel.FlxG;
import jp_2dgames.lib.CsvLoader;

/**
 * バトルのユーティリティ
 **/
class BtlUtil {

  /**
   * 敵グループの作成
   **/
  public static function createEnemyGroup(stage:Int):Void {
    var csv = new CsvLoader(Reg.PATH_CSV_ENEMY_GROUP);
    var enemyList = new List<Int>();

    for(i in 0...BtlMgr.ENEMY_APPEAR_MAX) {
      var id = csv.getInt(stage, 'enemy0${i+1}');
      if(id > 0) {
        enemyList.add(id);
      }
    }

    var cnt = enemyList.length;
    var baseX = FlxG.width/(cnt+1);
    var dx = baseX;
    var param = new Params();
    var idx = 0;
    for(enemyID in enemyList) {
      param.id = enemyID;
      var e = ActorMgr.recycle(BtlGroup.Enemy, param);
      var px = (baseX + (dx*idx)) - e.width/2;
      var py = FlxG.height/2 - e.height/2;
      if(cnt >= 3) {
        if(idx%2 == 1) {
          py += MyButton.HEIGHT;
        }
      }
      e.setDrawPosition(px, py);

      idx++;
    }
  }
}
