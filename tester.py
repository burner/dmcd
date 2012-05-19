#!/usr/bin/python

import glob
import re

def globTests(): # get all tests that fit the form
	testCaseRegex = re.compile("tests/test[0-9]+\.d")
	testCaseNumber = re.compile("[0-9]+")
	return sorted([ i for i in glob.glob("tests/test[0-9]*.d") if testCaseRegex.match(i) != None],
		key = lambda i: int(testCaseNumber.search(i).group(0)))

if __name__ == "__main__":
	print(globTests())
