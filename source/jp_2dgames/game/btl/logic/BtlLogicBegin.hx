package jp_2dgames.game.btl.logic;

import flixel.util.FlxColor;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.gui.BtlPlayerUI;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.btl.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.actor.Actor;

// 開始演出種別
enum BtlLogicBegin {
  Attack;    // 攻撃
  PowerUp;   // パワーアップ
  PowerDown; // パワーダウン
}

class BtlLogicBeginUtil {
  public static function start(type:BtlLogicBegin, target:Actor):Void {
    switch(type) {
      case BtlLogicBegin.Attack:
        // 通常攻撃
        _attack(target);
      case BtlLogicBegin.PowerUp:
        // パワーアップ
        _powerup(target);
      case BtlLogicBegin.PowerDown:
        // パワーダウン
        _powerdown(target);
    }
  }

  /**
   * 通常攻撃
   **/
  private static function _attack(target:Actor):Void {
    if(target.group == BtlGroup.Enemy) {
      var px = target.xcenter;
      var py = target.ycenter;
      Particle.start(PType.Hit, px, py, MyColor.ASE_YELLOW, true);
    }
    else {
      var px = BtlPlayerUI.getCenterX(target.ID);
      var py = BtlPlayerUI.getCenterY(target.ID);
      Particle.start(PType.Hit, px, py, MyColor.ASE_YELLOW, false);
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
      Particle.start(PType.Blade, px, py, FlxColor.RED, true);
      target.startAnimColor(FlxColor.RED);
    }
    else {
      var px = BtlPlayerUI.getCenterX(target.ID);
      var py = BtlPlayerUI.getCenterY(target.ID);
      Particle.start(PType.Blade, px, py, FlxColor.RED, false);
    }
    Snd.playSe("powerup");
  }

  /**
   * パワーダウン
   **/
  private static function _powerdown(target:Actor):Void {
    if(target.group == BtlGroup.Enemy) {
      var px = target.xcenter;
      var py = target.ycenter;
      target.startAnimColor(FlxColor.YELLOW);
      target.shake(0.25);
    }
    else {
      BtlPlayerUI.shake();
    }
    Snd.playSe("powerdown");
  }
}
