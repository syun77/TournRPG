package jp_2dgames.game.shop;
import flixel.util.FlxRandom;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.util.Generator;
import jp_2dgames.game.skill.SkillConst;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.item.ItemData;

/**
 * ショップデータ
 **/
class ShopData {

  // 消耗品
  var _itemList:Array<ItemData>;
  public var itemList(get, never):Array<ItemData>;
  function get_itemList() {
    return _itemList;
  }

  // 装備品
  var _equipList:Array<ItemData>;
  public var equipList(get, never):Array<ItemData>;
  function get_equipList() {
    return _equipList;
  }

  // スキル
  var _skillList:Array<SkillData>;
  public var skillList(get, never):Array<SkillData>;
  function get_skillList() {
    return _skillList;
  }

  // 食糧
  var _food:Int = 0;
  public var food(get, never):Int;
  function get_food() {
    return _food;
  }

  public function isEmptyItem():Bool {
    return itemList.length == 0;
  }
  public function isEmptyEquip():Bool {
    return equipList.length == 0;
  }
  public function isEmptySkill():Bool {
    return skillList.length == 0;
  }

  public function isEmptyFood():Bool {
    return _food == 0;
  }

  /**
   * 食糧を減らす
   **/
  public function subFood():Void {
    _food--;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    init();
  }

  /**
   * 初期化
   **/
  public function init() {
    _itemList = new Array<ItemData>();
    _equipList = new Array<ItemData>();
    _skillList = new Array<SkillData>();
  }

  /**
   * テストデータ
   **/
  public function testdata():Void {

    init();

    // CSV読み込み
    var csvItem = new CsvLoader(Reg.PATH_CSV_FIELD_ITEM);
    var csvSkill = new CsvLoader(Reg.PATH_CSV_FIELD_SKILL);

    // アイテム
    {
      var cnt = FlxRandom.intRanged(3, 6);
      var ret = Generator.getItemFromCategory(csvItem, IType.Potion, cnt);
      for(itemid in ret) {
        var item = new ItemData(itemid);
        _itemList.push(item);
      }
    }

    // 武器
    {
      var cnt = FlxRandom.intRanged(0, 3);
      var ret = Generator.getItemFromCategory(csvItem, IType.Weapon, cnt);
      for(itemid in ret) {
        var item = new ItemData(itemid);
        _equipList.push(item);
      }
    }
    // 防具
    {
      var cnt = FlxRandom.intRanged(0, 3);
      var ret = Generator.getItemFromCategory(csvItem, IType.Armor, cnt);
      for(itemid in ret) {
        var item = new ItemData(itemid);
        _equipList.push(item);
      }
    }

    // スキル
    {
      var cnt = FlxRandom.intRanged(1, 3);
      for(i in 0...cnt) {
        var skillID = Generator.getItem(csvSkill);
        var skill = new SkillData(skillID);
        _skillList.push(skill);
      }
    }

    // 食糧
    _food = FlxRandom.intRanged(3, 5);

  }

  /**
   * 外部から設定する
   **/
  public function set(items:Array<ItemData>, equips:Array<ItemData>, skills:Array<SkillData>, nFood:Int):Void {
    _itemList = items;
    _equipList = equips;
    _skillList = skills;

    _food = nFood;
  }

}
