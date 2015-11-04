package jp_2dgames.game.skill;

/**
 * スキルスロット
 **/
import jp_2dgames.game.gui.SkillUI;
class SkillSlot {

  // スキルスロットの最大数
  private static inline var LIMIT_FIRST:Int = 3;

  // ■static変数
  // シングルトン
  private static var _instance:SkillSlot = null;

  // ■static関数
  /**
   * 生成
   **/
  public static function create(skillList:Array<SkillData>):Void {
    _instance = new SkillSlot(skillList);
  }

  /**
   * 破棄
   **/
  public static function destroy():Void {
    _instance = null;
  }

  /**
   * スキルリストを設定する
   **/
  public static function setSkillList(skillList:Array<SkillData>):Void {
    _instance._init(skillList);
  }

  /**
   * 所持スキル数を取得する
   **/
  public static function count():Int {
    return _instance._countSkill();
  }

  /**
   * スキルを所持していないかどうか
   **/
  public static function isEmpty():Bool {
    return count() <= 0;
  }

  /**
   * 指定の番号のスキルを取得する
   **/
  public static function getSkill(idx:Int):SkillData {
    return _instance._getSkill(idx);
  }

  /**
   * スキルを追加
   **/
  public static function addSkill(skill:SkillData):Void {
    return _instance._addSkill(skill);
  }

  /**
   * スキルを削除
   **/
  public static function delSkill(idx:Int):Void {
    return _instance._delSkill(idx);
  }

  /**
   * 属性ブースト値を取得する
   **/
  public static function getBoost(attr:SkillAttr):Float {
    return _instance._getBoost(attr);
  }

  /**
   * 属性耐性値を取得する
   **/
  public static function getRegist(attr:SkillAttr):Float {
    return _instance._getRegist(attr);
  }


  // ================================================
  // ■以下インスタンス変数
  // ================================================
  // スキルリスト
  var _skillList:Array<SkillData>;
  public var skillList(get, never):Array<SkillData>;
  private function get_skillList() {
    return _skillList;
  }

  /**
   * コンストラクタ
   **/
  public function new(skillList:Array<SkillData>) {
    _init(skillList);
  }

  /**
   * 初期化
   **/
  private function _init(skillList:Array<SkillData>):Void {
    _skillList = skillList;
  }

  /**
   * まとめて実行する
   **/
  private function _forEach(func:SkillData->Void):Void {
    for(skill in _skillList) {
      func(skill);
    }
  }

  /**
   * スキル所持数を取得する
   **/
  private function _countSkill():Int {
    return skillList.length;
  }

  /**
   * 指定の番号に対応するスキルデータを取得する
   **/
  private function _getSkill(idx:Int):SkillData {
    return skillList[idx];
  }

  /**
   * スキルを追加
   **/
  private function _addSkill(skill:SkillData):Void {
    skillList.push(skill);
  }

  /**
   * スキルを削除
   **/
  private function _delSkill(idx:Int):Void {
    skillList.splice(idx, 1);
  }

  /**
   * 属性ブースト値を取得する
   **/
  private function _getBoost(attr:SkillAttr):Float {
    var ratio:Float = 1;
    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.AutoAttr) {
        if(skill.attr == attr) {
          var boost = SkillUtil.getParam(skill.id, "boost");
          ratio += (boost * 0.01);
        }
      }
    });

    return ratio;
  }

  /**
   * 属性耐性値を取得する
   **/
  private function _getRegist(attr:SkillAttr):Float {
    var ratio:Float = 1;
    _forEach(function(skill:SkillData) {
      if(skill.type == SkillType.AutoAttr) {
        if(skill.attr == attr) {
          var regist = SkillUtil.getParam(skill.id, "regist");
          ratio -= (regist * 0.01);
        }
      }
    });

    if(ratio < 0) {
      return 0;
    }
    return ratio;
  }
}
