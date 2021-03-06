#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
# 敵データ
python xls2csv.py enemy.xlsx ../assets/data/csv header_enemy.txt,header_item.txt
# プレイヤーデータ
python xls2csv.py player.xlsx ../assets/data/csv header_item.txt,header_skill.txt
# メッセージデータ
python xls2csv.py message.xlsx ../assets/data/csv
# アイテム
python xls2csv.py item.xlsx ../assets/data/csv header_item.txt
# スキル
python xls2csv.py skill.xlsx ../assets/data/csv header_skill.txt
# 出現アイテム
python xls2csv.py field.xlsx ../assets/data/csv header_item.txt,header_skill.txt
# イベントメッセージ
#python xls2csv.py event.xlsx ../assets/events
# 実績
#python xls2csv.py achievement.xlsx ../assets/data header_enemy.txt

# 定数ヘッダ出力
python export_const.py header_item.txt ../source/jp_2dgames/game/item
python export_const.py header_enemy.txt ../source/jp_2dgames/game/actor
python export_const.py header_skill.txt ../source/jp_2dgames/game/skill

#read Wait

# ターミナルを閉じる
#killall Terminal
