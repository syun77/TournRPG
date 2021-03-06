package jp_2dgames.game.field;

import jp_2dgames.game.gui.message.UIMsg;

/**
 * フィールドで発生する効果
 **/
enum FieldEffect {
  None;   // 特になし
  Damage; // ターン経過でダメージ
  Poison; // 毒付着
}

class FieldEffectUtil {

  /**
   * 種別を文字列に変換する
   **/
  public static function toString(type:FieldEffect):String {
    return '${type}';
  }

  /**
   * 文字列をイベント種別に変換する
   **/
  public static function fromString(str:String):FieldEffect {
    switch(str) {
      case 'None':   return FieldEffect.None;
      case 'Damage': return FieldEffect.Damage;
      case 'Poison': return FieldEffect.Poison;
      default:
        throw 'Invalid FieldType type: ${str}';
        return FieldEffect.None;
    }
  }

  /**
   * 色に変換する
   **/
  public static function toColor(type:FieldEffect):Int {
    switch(type) {
      case FieldEffect.None:
        return MyColor.ASE_WHITE;
      case FieldEffect.Damage:
        return MyColor.ASE_RED;
      case FieldEffect.Poison:
        return MyColor.ASE_PURPLE;
    }
  }

  /**
   * メッセージに変換する
   **/
  public static function toMsg(type:FieldEffect):String {
    var id:Int = 0;
    switch(type) {
      case FieldEffect.None:
        return "";
      case FieldEffect.Damage:
        id = UIMsg.FIELD_DAMAGE;
      case FieldEffect.Poison:
        id = UIMsg.FIELD_POISON;
    }

    return UIMsg.get(id);
  }
}
