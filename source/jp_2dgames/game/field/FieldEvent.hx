package jp_2dgames.game.field;

/**
 * イベントの種類
 **/
enum FieldEvent {
  None;   // 何もなし
  Random; // ランダム
  Goal;   // ゴール地点
  Enemy;  // 敵
  Item;   // アイテム
}

class FieldEventUtil {

  /**
   * イベント種別を文字列に変換する
   **/
  public static function toString(ev:FieldEvent):String {
    return '${ev}';
  }

  /**
   * 文字列をイベント種別に変換する
   **/
  public static function fromString(str:String):FieldEvent {
    switch(str) {
      case 'None':   return FieldEvent.None;
      case 'Random': return FieldEvent.Random;
      case 'Goal':   return FieldEvent.Goal;
      case 'Enemy':  return FieldEvent.Enemy;
      case 'Item':   return FieldEvent.Item;
      default:
        throw 'Invalid FieleEvent type: ${str}';
        return FieldEvent.None;
    }
  }
}