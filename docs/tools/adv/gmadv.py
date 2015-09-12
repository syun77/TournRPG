#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Created on 2014/01/18
@note: エントリポイント
@author: syun
"""


from lexer  import Lexer, LexerReader
from my_parser import MyParser
import sys

def main():

    # コマンドライン引数を取得
    args = sys.argv

    # 関数定義
    funcs = args[1]
    # 入力ファイル
    infile = args[2]
    # 出力ファイル
    outfile = args[3]

    # 字句解析する
    parser = MyParser(
        Lexer(LexerReader(infile)),
        funcs)
    # 構文解析する
    parser.parse(outfile)

if __name__ == "__main__":
    main()

