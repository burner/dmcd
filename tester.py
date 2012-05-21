#!/usr/bin/python

import glob
import re
import subprocess

def globTests(): # get all tests that fit the form
	testCaseRegex = re.compile("tests/test[0-9]+\.d")
	testCaseNumber = re.compile("[0-9]+")
	return sorted([ i for i in glob.glob("tests/test[0-9]*.d") if testCaseRegex.match(i) != None],
		key = lambda i: int(testCaseNumber.search(i).group(0)))

def getTestInformation(filename):
	f = open(filename)
	testInfor = [ i[4:] for i in f if i.startswith("//T ") ]
	ret = dict()
	for i in testInfor:
		colon = i.find(':')
		if colon != -1:
			ret[i[:colon].strip(" \t\r\n")] = i[colon+1:].strip(" \t\r\n")
		else:
			ret["desc"] = i.strip(" \t\r\n")

	return ret

def runTest(filename):
	inp = ("./dmcd -f ").split()
	inp[1] += " " + filename
	print(inp)
	ret = subprocess.Popen(inp, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
	ret.wait()

def doTest(filename):
	info = getTestInformation(filename)
	runTest(filename)

if __name__ == "__main__":
	files = globTests()
	for i in files:
		print(doTest(i))
