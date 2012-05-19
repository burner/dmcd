#!/usr/bin/python

import glob
import re

def globTests(): # get all tests that fit the form
	testCaseRegex = re.compile("tests/test[0-9]+\.d")
	return sorted([ i for i in glob.glob("tests/test[0-9][0-9]*.d") if testCaseRegex.match(i) != None])

if __name__ == "__main__":
	print(globTests())
