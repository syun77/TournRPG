#!/usr/bin/env python
# -*- coding: utf-8 -*-

from code      import Code

""" 構文木定数クラス """
class Define:
	def __init__(self, value):
		self.value = value
	def getValue(self):
		return self.value
	def run(self, writer):
		# 命令書き込み
		pass
		