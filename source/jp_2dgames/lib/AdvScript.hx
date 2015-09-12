package jp_2dgames.lib;

import flixel.FlxG;
import openfl.Assets;

/**
 * ADVゲーム用スクリプト
 **/
class AdvScript {

  // ■定数
  public static inline var RET_CONTINUE:Int = 0;
  public static inline var RET_YIELD:Int    = 1;

  // ■スタティック

  // ■メンバ変数
  // スクリプトデータ
  var _data:Array<String>;
  // 実行カウンタ
  var _pc:Int;
  // 終了コードが見つかったかどうか
  var _bEnd:Bool;
  // システムコマンド定義
  var _sysTbl:Map<String,Array<String>->Void>;
  // ユーザコマンド定義
  var _userTbl:Map<String,Array<String>->Int>;
  // ログを出力するかどうか
  var _bLog:Bool = false;

  // 変数スタック
  var _stack:List<Int>;
  public function popStack():Int {
    return _stack.pop();
  }

  /**
   * コンストラクタ
   **/
  public function new(cmdTbl:Map<String,Array<String>->Int>, filepath:String=null) {
    if(filepath != null) {
      // 読み込み
      load(filepath);
    }

    // システムテーブル登録
    _sysTbl = [
      "END" => _END,
      "INT" => _INT,
    ];

    _userTbl = cmdTbl;
    _stack = new List<Int>();
  }

  /**
   * 読み込み
   **/
  public function load(filepath):Void {
    var scr:String = Assets.getText(filepath);
    if(scr == null) {
      // 読み込み失敗
      FlxG.log.warn("AdvScript.load() scr is null. file:'" + filepath + "''");
      return;
    }

    // 変数初期化
    _data = scr.split("\n");
    _pc   = 0;
    _bEnd = false;
  }

  /**
   * ログを有効化するかどうか
   **/
  public function setLog(b:Bool):Void {
    _bLog = b;
  }

  /**
   * 実行カウンタを最初に戻す
   **/
  public function resetPc():Void {
    _pc = 0;
    _bEnd = false;
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    if(_bEnd) {
      return true;
    }
    return _pc >= _data.length;
  }

  /**
   * 更新
   **/
  public function update():Void {
    while(isEnd() == false) {
      var ret = _loop();
      if(ret == RET_YIELD) {
        // いったん抜ける
        break;
      }
    }
  }

  /**
   * ループ
   **/
  private function _loop():Int {
    var line = _data[_pc];
    if(line == "") {
      _pc++;
      return RET_CONTINUE;
    }

    var d = line.split(",");
    _pc++;
    var cmd = d[0];
    var param = d.slice(1);

    var ret = RET_CONTINUE;

    if(_sysTbl.exists(cmd)) {
      _sysTbl[cmd](param);
      ret = RET_CONTINUE;
    }
    else {
      ret = _userTbl[cmd](param);
    }

    return ret;
  }

  private function _INT(param:Array<String>):Void {
    var p0 = Std.parseInt(param[0]);
    if(_bLog) {
      trace('[AI] INT ${p0}');
    }
    _stack.push(p0);
  }
  private function _END(param:Array<String>):Void {
    if(_bLog) {
      trace("[AI] END");
      trace("-------------------");
    }
    _bEnd = true;
  }
}
