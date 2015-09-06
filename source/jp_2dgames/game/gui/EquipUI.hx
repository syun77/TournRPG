package jp_2dgames.game.gui;

import flixel.group.FlxSpriteGroup;

/**
 * 装備品UI
 **/
class EquipUI extends FlxSpriteGroup {

  // ■定数

  // 座標
  private static inline var BASE_X:Int = 120;
  private static inline var BASE_Y:Int = 120;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(BASE_X, BASE_Y);


  }
}
