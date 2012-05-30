#!/usr/bin/python

import glob
import sys
import re
import subprocess
from lxml import etree
from collections import defaultdict
from datetime import datetime

testCaseNumber = re.compile("[0-9]+")

bodytext = "dmdc is a Compiler utilizing dex and dalr for lexer and parser generation.  Libhurt is used as std library in combination with the druntime. The Compiler will be split in two separate programs.\n The compiler daemon which will run until it is advise to quit. This daemon does the compiler, the work distribution as well as the caching.\n The other part is the driver program. It tells the backend what to compile and gives the user feedback about his compile.\n"

typesNames = ["Lexing", "Parsing", "Compiling", "Running", "Compile Time", 
	"Running Time"]

def typeNameToXml(name):
	if name == "Compile Time":
		return "compileTime"
	elif name == "Running Time":
		return "runTime"
	else:
		return name

def globTests(): # get all tests that fit the form
	testCaseRegex = re.compile("tests/test[0-9]+\.d")
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
	inp = ("./dmcd")
	inp += " " + filename
	print(inp)
	ret = subprocess.Popen(inp, stdout=subprocess.PIPE, 
		stderr=subprocess.PIPE, shell=True)
	ret.wait()

def doTest(filename):
	info = getTestInformation(filename)
	runTest(filename)

def toHTML_XML(sortedNames, dates, data):
	root = etree.Element("html")
	title = etree.SubElement(root, "title")
	title.text = "Distributed multithreaded caching D compiler"
	headline = etree.SubElement(root, "h1")
	headline.text = "Distributed multithreaded caching D compiler"
	body = etree.SubElement(root, "body")
	body.text = bodytext

	center = etree.SubElement(body, "center")
	table = etree.SubElement(center, "table")
	table.attrib["border"] = str(1)
	topRow = etree.SubElement(table, "tr")
	date = etree.SubElement(topRow, "td")
	date.text = "Date"
	category = etree.SubElement(topRow, "td")
	category.text = "Category"
	for name in sortedNames:
		tmp = etree.SubElement(topRow, "td")
		tmp.text = name[:-2]

	for date in dates:
		for typ in typesNames:
			row = etree.SubElement(table, "tr")
			tmp = etree.SubElement(row, "td")
			tmp.text = date.strftime("%Y-%m-%d %H:%M:%S")
			tmp = etree.SubElement(row, "td")
			tmp.text = typ
			for name in sortedNames:
				tmp = etree.SubElement(row, "td", 
					getValueByDateNameAndType(data, date, name, 
					typeNameToXml(typ)))
				tmp.text = tmp.attrib["text"]
			

	#print(etree.tostring(root, pretty_print=True))
	sys.stdout.buffer.write(etree.tostring(root, pretty_print=True))
	sys.stdout.flush()

def getSortedTestNames(date):
	#print(date)
	sortedUniqueTestName = sorted(
		list(set(
			[ value["test"] for key in date for value in date[key]])),
			key = lambda i: int(testCaseNumber.search(i).group(0))
		)

	return sortedUniqueTestName

def getSortedDateTimes(date):
	dates = sorted(
		[ datetime.strptime(key, "%Y-%m-%d %H:%M:%S") for key in date])
	return dates

def getValueByDateNameAndType(data, date, name, typ):
	dateValues = data[date.strftime("%Y-%m-%d %H:%M:%S")]
	for it in dateValues:
		if it["test"] == name and it["testtype"] == typ:
			return it

def readReadme():
	rest = []
	date = defaultdict(list)
	context = etree.iterparse("README")

	# parse the existing tests
	for action, elem in context:
		if elem.tag == "tr":
			for td in elem.iter():
				if "testtype" in td.attrib:
					date[td.attrib.get("date")].append(
						{"test":td.attrib.get("test"),
						"testtype":td.attrib.get("testtype"), 
						"bgcolor":td.attrib.get("bgcolor"), "text":td.text})
				else:
					rest.append(td)

	#print(date, [etree.tostring(i) for i in rest])
	#print(date)
	return (date,rest)

			
if __name__ == "__main__":
	dr = readReadme()
	#print(dr[0])
	names = getSortedTestNames(dr[0])
	sortedDates = getSortedDateTimes(dr[0])
	toHTML_XML(names, sortedDates, dr[0])
