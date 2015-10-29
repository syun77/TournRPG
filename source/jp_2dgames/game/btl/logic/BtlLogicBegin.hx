package jp_2dgames.game.btl.logic;

import flixel.util.FlxColor;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.gui.BtlUI;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.Actor;

// 開始演出種別
enum BtlLogicBegin {
  Attack; // 攻撃
  PowerUp; // パワーアップ
}

class BtlLogicBeginUtil {
  public static function start(type:BtlLogicBegin, target:Actor):Void {
    switch(type) {
      case BtlLogicBegin.Attack:
        _attack(target);
      case BtlLogicBegin.PowerUp:
        _powerup(target);
    }
  }

  /**
   * 攻撃
   **/
  private static function _attack(target:Actor):Void {
    if(target.group == BtlGroup.Enemy) {
      var px = target.xcenter;
      var py = target.ycenter;
      Particle.start(PType.Hit, px, py, FlxColor.YELLOW, true);
    }
    else {
      var px = BtlUI.getCenterX(target.ID);
      var py = BtlUI.getCenterY(target.ID);
      Particle.start(PType.Hit, px, py, FlxColor.YELLOW, false);
    }
    Snd.playSe("hit2");
  }

  /**
   * パワーアップ
   **/
  private static function _powerup(target:Actor):Void {
    if(target.group == BtlGroup.Enemy) {
      var px = target.xcenter;
      var py = target.ycenter;
      Particle.start(PType.Blade, px, py, FlxColor.YELLOW, true);
    }
    else {
      var px = BtlUI.getCenterX(target.ID);
      var py = BtlUI.getCenterY(target.ID);
      Particle.start(PType.Blade, px, py, FlxColor.YELLOW, false);
    }
    Snd.playSe("powerup");
  }
}
