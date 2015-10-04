package jp_2dgames.game.util;

import jp_2dgames.lib.CsvLoader;
import flixel.util.FlxRandom;

/**
 * 生成情報
 **/
private class GenerateInfo {
  private var _idxs:Array<Int>;   // 出現するIDの配列
  private var _ratios:Array<Int>; // 出現確率の配列
  private var _sum:Int;           // 確率の合計

  /**
   * コンストラクタ
   **/
  public function new(csv:CsvLoader) {
    // 変数初期化
    _idxs   = new Array<Int>();
    _ratios = new Array<Int>();
    _sum    = 0;

    // アイテムの情報
    var floor = Global.getStage();
    csv.foreach(function(v:Map<String,String>) {
      var start = Std.parseInt(v.get("start"));
      var end = Std.parseInt(v.get("end"));
      var id = Std.parseInt(v.get("itemid"));
      var ratio = Std.parseInt(v.get("ratio"));
      if(start <= floor && floor <= end) {
        _idxs.push(id);
        _ratios.push(ratio);
        _sum += ratio;
      }
    });
  }

  /**
   * ランダムにIDを決定する
   **/
  public function generate():Int {
    // ランダムで決定する
    var rnd = FlxRandom.intRanged(0, _sum-1);
    var idx:Int = 0;
    for(ratio in _ratios) {
      if(rnd < ratio) {
        // マッチした
        return _idxs[idx];
      }
      rnd -= ratio;
      idx++;
    }

    // 見つからなかった
    return 0;
  }
}

/**
 * 自動生成
 **/
class Generator {

  /**
   * アイテムを生成
   **/
  public static function getItem(csv:CsvLoader):Int {
    var gen = new GenerateInfo(csv);
    return gen.generate();
  }
}
