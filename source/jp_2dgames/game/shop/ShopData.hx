package jp_2dgames.game.shop;
import jp_2dgames.game.skill.SkillConst;
import jp_2dgames.game.skill.SkillData;
import jp_2dgames.game.item.ItemConst;
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

  public function isEmptyItem():Bool {
    return itemList.length == 0;
  }
  public function isEmptyEquip():Bool {
    return equipList.length == 0;
  }
  public function isEmptySkill():Bool {
    return skillList.length == 0;
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
    // TODO: 仮データ追加
    var item = new ItemData(ItemConst.POTION01);
    _itemList.push(item);

    item = new ItemData(ItemConst.WEAPON01);
    _equipList.push(item);
    item = new ItemData(ItemConst.WEAPON02);
    _equipList.push(item);

    var skill = new SkillData(SkillConst.SKILL001);
    _skillList.push(skill);
    skill = new SkillData(SkillConst.SKILL502);
    _skillList.push(skill);

  }

  /**
   * 外部から設定する
   **/
  public function set(items:Array<ItemData>, equips:Array<ItemData>, skills:Array<SkillData>):Void {
    _itemList = items;
    _equipList = equips;
    _skillList = skills;
  }

}
