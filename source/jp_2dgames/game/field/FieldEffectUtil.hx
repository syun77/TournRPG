package jp_2dgames.game.field;

/**
 * フィールドで発生する効果
 **/
enum FieldEffect {
  None;   // 特になし
  Damage; // ターン経過でダメージ
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
      default:
        throw 'Invalid FieldType type: ${str}';
        return FieldEffect.None;
    }
  }
}
