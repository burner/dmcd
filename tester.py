#!/usr/bin/python

import xml.dom.minidom
import itertools
import glob
import sys
import re
from lxml import etree
from collections import defaultdict
from datetime import datetime, timedelta

from os import kill
import os.path
from signal import alarm, signal, SIGALRM, SIGKILL
from subprocess import PIPE, Popen

def run(args, cwd = None, shell = False, kill_tree = True, timeout = -1, env = None):
	'''
	Run a command with a timeout after which it will be forcibly
	killed.
	'''
	class Alarm(Exception):
		pass
	def alarm_handler(signum, frame):
		raise Alarm
	p = Popen(args, shell = shell, cwd = cwd, stdout = PIPE, stderr = PIPE, env = env)
	if timeout != -1:
		signal(SIGALRM, alarm_handler)
		alarm(timeout)
	try:
		stdout, stderr = p.communicate()
		if timeout != -1:
			alarm(0)
	except Alarm:
		pids = [p.pid]
		if kill_tree:
			pids.extend(get_process_children(p.pid))
		for pid in pids:
			# process might have died before getting to this line
			# so wrap to avoid OSError: no such process
			try: 
				kill(pid, SIGKILL)
			except OSError:
				pass
		return 65, '', ''
	return p.returncode, stdout, stderr

def get_process_children(pid):
	p = Popen('ps --no-headers -o pid --ppid %d' % pid, shell = True,
			  stdout = PIPE, stderr = PIPE)
	stdout, stderr = p.communicate()
	return [int(p) for p in stdout.split()]

testCaseNumber = re.compile("[0-9]+")

color = {True:"green", False:"red"}

styleText = "tr.top td { border-top: thick solid black; }\ntr.bottom td { border-bottom: thick solid black; }\ntr.row td:first-child { border-left: thin solid black; }\ntr.row td:last-child { border-right: thin solid black; }\n"

bodytext = "dmdc is a Compiler utilizing dex and dalr for lexer and parser generation.  Libhurt is used as std library in combination with the druntime. The Compiler will be split in two separate programs.\n The compiler daemon which will run until it is advise to quit. This daemon does the compiler, the work distribution as well as the caching.\n The other part is the driver program. It tells the backend what to compile and gives the user feedback about his compile.\n"

typeNames = ["Lexer", "Parser", "Semantic", "Compiles", "Retval", "Compile Time", "Running Time"]

options = [ ["-l true", "-l false"], ["-t 1", "-t 5", "-t 10", "-t 25", "-t 50"]
]

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

	table = etree.SubElement(body, "table")
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
		for typ in typeNames:
			row = etree.SubElement(table, "tr")
			if typ == "Lexer":
				row.attrib["class"] = "top row"
			tmp = etree.SubElement(row, "td", {"typ":"date"})
			tmp.text = date.strftime("%Y-%m-%d %H:%M:%S")
			tmp = etree.SubElement(row, "td")
			tmp.text = typ
			for name in sortedNames:
				vals = getValueByDateNameAndType(data, date, name, typ)
				tmp = etree.SubElement(row, "td", vals)
				tmp.attrib["date"] = date.strftime("%Y-%m-%d %H:%M:%S")
				if "text" in tmp.attrib:
					tmp.text = vals["text"] 
			

	return root

def getSortedTestNames(date):
	names =	[ value["test"] for key in date for value in date[key]]	
	nameSet = list(set(names))
	sor = sorted(nameSet, 
		key = lambda i: int(testCaseNumber.search(i).group(0)))

	return sor

def getSortedDateTimes(date):
	dates = sorted(
		[ datetime.strptime(key, "%Y-%m-%d %H:%M:%S") for key in date], 
		reverse=True)
	return dates

def subNoneTypes(dic):
	for k in dic:
		if dic[k] == None:
			dic[k] == ""

def getValueByDateNameAndType(data, date, name, typ):
	dateValues = data[date.strftime("%Y-%m-%d %H:%M:%S")]
	for it in dateValues:
		if it["test"] == name:
			if typ != "Running Time" and typ != "Compile Time" and typ != "Retval":
				it["bgcolor"] = color[it[typ] == it[typ.lower()]]
				it["text"] = it[typ.lower()]
			elif typ == "Retval":
				it["text"] = it[typ]
				it["bgcolor"] = "red"
			elif typ == "Running Time":
				it["text"] = it["runTime"]
				it["bgcolor"] = "white"
			elif typ == "Compile Time":
				it["text"] = it["compileTime"]
				it["bgcolor"] = "white"
			return it

	return {}

def isInList(lst, testname):
	for it in lst:
		if it["test"] == testname:
			return True
	
	return False

def readReadme(name):
	date = defaultdict(list)
	context = etree.iterparse(name)

	# parse the existing tests
	for action, elem in context:
		if elem.tag == "tr":
			datum = ""
			for td in elem.iter():
				if "typ" in td.attrib and td.attrib["typ"] == "date":
					datum = td.text
				if "test" in td.attrib and not isInList(date[datum], td.attrib["test"]):
					tmp = td.attrib
					if "bgcolor" in tmp:
						del tmp["bgcolor"]

					date[datum].append(tmp)
					
					

	return date

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

	for i in ["compiles", "lexer", "parser", "semantic"]:
		if i not in ret:
			ret[i] = "yes"	

	if "retval" not in ret:
		ret["retval"] = "0"

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
	rc = run(inp, shell=True, timeout = 12);
	after = datetime.now();
	return (rc[0], (after-before).total_seconds())

def doTest(filename):
	info = getTestInformation(filename)
	ri = runTest(filename)
	info["compileTime"] = str(ri[1])
	info["runTime"] = "0.0"
	if ri[0] == 0:
		info["Lexer"] = "yes"; info["Parser"] = "yes"; info["Retval"] = "0";
		info["Semantic"] = "yes"; info["Compiles"] = "yes";
	if ri[0] > 0 and ri[0] <= 32:
		info["Lexer"] = "no"; info["Parser"] = "no"; info["Retval"] = "0";
		info["Semantic"] = "no"; info["Compiles"] = "no";
	if ri[0] > 32 and ri[0] <= 64:
		info["Lexer"] = "yes"; info["Parser"] = "no"; info["Retval"] = "0";
		info["Semantic"] = "no"; info["Compiles"] = "no";
	if ri[0] > 64 and ri[0] <= 96:
		info["Lexer"] = "yes"; info["Parser"] = "yes"; info["Retval"] = "0";
		info["Semantic"] = "no"; info["Compiles"] = "no";
	if ri[0] > 96 and ri[0] <= 127:
		info["Lexer"] = "yes"; info["Parser"] = "yes"; info["Retval"] = "0";
		info["Semantic"] = "yes"; info["Compiles"] = "no";

	return info	

def runAllTests(date):
	tests = globTests()
	ret = []
	for i in tests:
		tmp = doTest(i)
		tmp["date"] = date.strftime("%Y-%m-%d %H:%M:%S")
		tmp["test"] = i[i.rfind('/')+1:]
		#print(tmp)
		ret.append(tmp)

	return ret

def getOldTestResults(filename):
	tree = etree.parse(filename)
			
if __name__ == "__main__":
	oldtest = {}
	if os.path.isfile("test2.html"):
		oldtest = readReadme("test2.html")
		#print(oldstuff)
	
	n = datetime.now()
	d = defaultdict(list)
	for i in runAllTests(n):
		d[n.strftime("%Y-%m-%d %H:%M:%S")].append(i)
	#print(d)

	merge = {}
	for key in oldtest:
		merge[key] = oldtest[key]

	for key in d:
		merge[key] = d[key]

	names = getSortedTestNames(merge)
	print(names)
	sortedDates = getSortedDateTimes(merge)
	print(sortedDates)
	root = toHTML_XML(names, sortedDates, merge)
	xml = xml.dom.minidom.parseString(etree.tostring(root))
	f = open("test2.html", 'w')
	f.write(xml.toprettyxml())
	f.close()
