#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import glob

def usage():
	print "Usage: conv_ai.py [gmadv.py] [define_functions.h] [input_dir] [output_dir]"

def main(tool, fFuncDef, inputDir, outDir):
	# *.txtを取得
	txtList = glob.glob("%s*.txt"%inputDir)

	for txt in txtList:
		fInput = txt
		fOut   = outDir + txt.replace(inputDir, "").replace(".txt", ".csv")

		cmd = "python %s %s %s %s"%(
			tool, fFuncDef, fInput, fOut)
		print cmd
		os.system(cmd)

if __name__ == '__main__':
	args = sys.argv
	argc = len(sys.argv)
	if argc < 4:
		# 引数が足りない
		usage()
		quit()

	# ツール
	tool = args[1]
	# 関数定義
	fFuncDef = args[2]
	# 入力フォルダ
	inputDir = args[3]
	# 出力フォルダ
	outDir = args[4]

	main(tool, fFuncDef, inputDir, outDir)
