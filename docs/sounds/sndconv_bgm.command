#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
python sndconv_bgm.py

#read Wait

# ターミナルを閉じる
#killall Terminal
