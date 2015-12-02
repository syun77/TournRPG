package jp_2dgames.game.state;

import jp_2dgames.game.actor.PlayerInfo;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.skill.SkillUtil;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.skill.SkillConst;
import flixel.FlxG;
import flixel.FlxState;

/**
 * ゲーム開始シーン
 **/
class PlayInitState extends FlxState {
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // ゲームグローバルパラメータ初期化
    Global.init();

    // プレイヤー初期装備取得
    var csv = new CsvLoader(Reg.PATH_CSV_PLAYER_INIT);
    var playerID:Int = 1;

    // 所持金を設定
    var money = csv.getInt(playerID, "money");
    Global.setMoney(money);

    // 食糧を設定
    var food = csv.getInt(playerID, 'food');
    Global.getPlayerParam().food = food;

    // 初期アイテムを設定
    for(i in 1...(5+1)) {
      var key = 'item${i}';
      var itemID = csv.getInt(playerID, key);
      if(itemID == ItemUtil.NONE) {
        continue;
      }
      var item = new ItemData(itemID);
      Inventory.push(item);
    }
    // 初期スキルを設定
    var skills = Global.getSkillSlot();
    for(i in 1...(5+1)) {
      var key = 'skill${i}';
      var skillID = csv.getInt(playerID, key);
      if(skillID == SkillUtil.NONE) {
        continue;
      }
      var skill = new SkillData(skillID);
      skills.push(skill);
    }
  }

  /**
   * 破棄
   */
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   */
  override public function update():Void {
    super.update();

    // ゲーム開始
    FlxG.switchState(new FieldState());
  }
}
