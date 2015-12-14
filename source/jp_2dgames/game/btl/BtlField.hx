package jp_2dgames.game.btl;

import jp_2dgames.game.field.FieldEffectUtil;
import jp_2dgames.game.particle.Particle;
import flixel.group.FlxSpriteGroup;

/**
 * バトルの地形
 **/
class BtlField extends FlxSpriteGroup {

  var _tAnim:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _tAnim++;
    var freq = 30 - BtlGlobal.getTurn();
    if(freq < 3) {
      freq = 3;
    }
    if(_tAnim%freq == 0) {
      var type = BtlGlobal.getFieldEffect();
      var color = FieldEffectUtil.toColor(type);
      switch(BtlGlobal.getFieldEffect()) {
        case FieldEffect.None:
          // 何もしない
        case FieldEffect.Damage:
          Particle.start(PType.Bubble, x, y, color, false);
      }
    }
  }
}
