package jp_2dgames.game.field;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

/**
 * フィールドのプレイヤーシンボル
 **/
class FieldPlayer extends FlxSprite {

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(Reg.PATH_FIELD_PLAYER_ICON, true);
    animation.add("play", [0, 1], 2);
    animation.play("play");
  }

  /**
   * ノードから座標を設定する
   **/
  public function setPositionFromNode(node:FieldNode):Void {

    x = node.x;
    y = node.y - node.height/2;
  }

  /**
   * 指定のノードに向かって移動する
   **/
  public function moveTowardNode(node:FieldNode, complete:Void->Void):Void {

    var px = node.x;
    var py = node.y - height/2;
    FlxTween.tween(this, {x:px, y:py}, 0.5, {ease:FlxEase.sineOut, complete:function(tween:FlxTween) {
      // 移動完了
      complete();
    }});
  }
}
