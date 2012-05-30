#!/usr/bin/python

import glob
import sys
import re
import subprocess
from lxml import etree
from collections import defaultdict
from datetime import datetime, timedelta

testCaseNumber = re.compile("[0-9]+")

color = {True:"green", False:"red"}

styleText = "tr.top td { border-top: thick solid black; }\ntr.bottom td { border-bottom: thick solid black; }\ntr.row td:first-child { border-left: thin solid black; }\ntr.row td:last-child { border-right: thin solid black; }\n"

bodytext = "dmdc is a Compiler utilizing dex and dalr for lexer and parser generation.  Libhurt is used as std library in combination with the druntime. The Compiler will be split in two separate programs.\n The compiler daemon which will run until it is advise to quit. This daemon does the compiler, the work distribution as well as the caching.\n The other part is the driver program. It tells the backend what to compile and gives the user feedback about his compile.\n"

typesNames = ["Lexing", "Parsing", "Semantic", "Compiling", "Running", "Compile Time", "Running Time"]

def typeNameToXml(name):
	if name == "Compile Time":
		return "compileTime"
	elif name == "Running Time":
		return "runTime"
	else:
		return name

def toHTML_XML(sortedNames, dates, data):
	root = etree.Element("html")
	header = etree.SubElement(root, "header")
	style = etree.SubElement(header, "style")
	style.attrib["type"] = "text/css"
	style.text = styleText
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
		tmp.text = name[:4] + " " + name[4:-2]

	for date in dates:
		for typ in typesNames:
			row = etree.SubElement(table, "tr")
			if typ == "Lexing":
				row.attrib["class"] = "top row"
			tmp = etree.SubElement(row, "td")
			tmp.text = date.strftime("%Y-%m-%d %H:%M:%S")
			tmp = etree.SubElement(row, "td")
			tmp.text = typ
			for name in sortedNames:
				tmp = etree.SubElement(row, "td", 
					getValueByDateNameAndType(data, date, name, 
					typeNameToXml(typ)))
				tmp.attrib["date"] = date.strftime("%Y-%m-%d %H:%M:%S")
				if "text" in tmp.attrib:
					tmp.text = tmp.attrib["text"]
			

	#print(etree.tostring(root, pretty_print=True))
	#sys.stdout.buffer.write(etree.tostring(root, pretty_print=True))
	#sys.stdout.flush()
	return root

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

def readReadme(name):
	rest = []
	date = defaultdict(list)
	context = etree.iterparse(name)

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

def globTests(): # get all tests that fit the form
	testCaseRegex = re.compile("tests/test[0-9]+\.d")
	return sorted([ i for i in glob.glob("tests/test[0-9]*.d") if testCaseRegex.match(i) != None],
		key = lambda i: int(testCaseNumber.search(i).group(0)))

def runTest(filename):
	inp = ("./dmcd")
	inp += " " + filename
	print(inp)
	before = datetime.now();
	ret = subprocess.Popen(inp, stdout=subprocess.PIPE, 
		stderr=subprocess.PIPE, shell=True)
	rc = ret.wait()
	after = datetime.now();
	return (rc, (after-before).total_seconds())

def doTest(filename):
	info = getTestInformation(filename)
	ri = runTest(filename)
	info["compileTime"] = str(ri[1])
	info["runTime"] = "0.0"
	if ri[0] == 0:
		info["Lexing"] = "yes"
		info["Parsing"] = "yes"
		info["Semantic"] = "yes"
		info["Compiling"] = "yes"
	if ri[0] < 32:
		info["Lexing"] = "no"
		info["Parsing"] = "no"
		info["Semantic"] = "no"
		info["Compiling"] = "no"
	if ri[0] < 64:
		info["Lexing"] = "yes"
		info["Parsing"] = "no"
		info["Semantic"] = "no"
		info["Compiling"] = "no"
	if ri[0] < 96:
		info["Lexing"] = "yes"
		info["Parsing"] = "yes"
		info["Semantic"] = "no"
		info["Compiling"] = "no"
	if ri[0] < 128:
		info["Lexing"] = "yes"
		info["Parsing"] = "yes"
		info["Semantic"] = "yes"
		info["Compiling"] = "no"

	return info	

def testDictToReadmeDict(di):
	print(di)
	l = [
		# Lexing
		{"test":di["test"],
		"testtype":"Lexing", "date":di["date"],
		"text":di["Lexing"],"bgcolor":color[di["lexer"] == di["Lexing"]]},
		# Parsing
		{"test":di["test"],
		"testtype":"Parsing", "date":di["date"],
		"text":di["Parsing"],"bgcolor":color[di["parser"] == di["Parsing"]]},
		# Semantic
		{"test":di["test"],
		"testtype":"Semantic", "date":di["date"],
		"text":di["Semantic"],"bgcolor":color[di["semantic"] == di["Semantic"]]},
		# Compiling
		{"test":di["test"],
		"testtype":"Compiling", "date":di["date"],
		"text":di["Compiling"],"bgcolor":color[di["compiles"] == di["Compiling"]]}]
		# Running
	if "retval" in di:
		l.append({"test":di["test"],
		"testtype":"Running", "date":di["date"],
		"text":di["retval"],"bgcolor":color[False]})
	else:
		l.append({"test":di["test"],
		"testtype":"Running", "date":di["date"],
		"text":"","bgcolor":color[False]})
	# Compile Time
	l.append({"test":di["test"],
	"testtype":"compileTime", "date":di["date"],
	"text":di["compileTime"],"bgcolor":"white"})
	# Running Time
	l.append({"test":di["test"],
	"testtype":"runTime", "date":di["date"],
	"text":di["runTime"],"bgcolor":"white"})

	return l
	

def runAllTests(date):
	tests = globTests()
	ret = []
	for i in tests[:54]:
		tmp = doTest(i)
		tmp["date"] = date.strftime("%Y-%m-%d %H:%M:%S")
		tmp["test"] = i[i.rfind('/')+1:]
		ret.append(tmp)

	return ret
			
if __name__ == "__main__":
	#dr = []
	dr = readReadme("test2.html")
	#dr = readReadme("README")
	#names = getSortedTestNames(dr[0])
	#sortedDates = getSortedDateTimes(dr[0])
	#root = toHTML_XML(names, sortedDates, dr[0])
	#et = etree.ElementTree(root)
	#et.write("README")
	n = datetime.now()
	l = []
	for i in runAllTests(n):
		l.extend(testDictToReadmeDict(i))

	d = {n.strftime("%Y-%m-%d %H:%M:%S"):l}
	for key in dr[0]:
		d[key] = dr[0][key]
	#print(d)
	names = getSortedTestNames(d)
	#print(names)
	sortedDates = getSortedDateTimes(d)
	print(sortedDates, type(sortedDates))
	reverse = []
	for i in sortedDates:
		reverse.insert(0, i)

	root = toHTML_XML(names, reverse, d)
	et = etree.ElementTree(root)
	et.write("test2.html")
	
	#print(l)
