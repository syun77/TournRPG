package jp_2dgames.game.util;

import jp_2dgames.game.item.ItemUtil;
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
  public function new(csv:CsvLoader, keyForID:String, fnCheck:Int->Bool) {
    // 変数初期化
    _idxs   = new Array<Int>();
    _ratios = new Array<Int>();
    _sum    = 0;

    // フロア数
    var floor = Global.getFloor();
    csv.foreach(function(v:Map<String,String>) {
      var start = Std.parseInt(v.get("start"));
      var end = Std.parseInt(v.get("end"));
      var id = Std.parseInt(v.get(keyForID));
      var ratio = Std.parseInt(v.get("ratio"));
      if(start <= floor && floor <= end) {
        // 対称のフロア
        if(fnCheck(id)) {
          _idxs.push(id);
          _ratios.push(ratio);
          _sum += ratio;
        }
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
    var gen = new GenerateInfo(csv, "itemid", function(id:Int) {
      return true;
    });
    return gen.generate();
  }

  /**
   * カテゴリ指定でアイテムを生成
   * @param csvItem  アイテム出現テーブル
   * @param type アイテム種別
   * @param cnt  出現数
   **/
  public static function getItemFromCategory(csv:CsvLoader, type:IType, cnt:Int):List<Int> {
    var gen = new GenerateInfo(csv, "itemid", function(id:Int) {
      var itemtype = ItemUtil.toType(id);
      return (itemtype == type);
    });

    var ret = new List<Int>();
    for(i in 0...cnt) {
      ret.add(gen.generate());
    }

    return ret;
  }

  /**
   * 敵グループを生成
   **/
  public static function getEnemyGroup(csv:CsvLoader):Int {
    var gen = new GenerateInfo(csv, "id", function(id:Int) {
      return true;
    });
    return gen.generate();
  }
}
