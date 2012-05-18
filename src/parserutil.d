module parserutil;

import parsetable;

import hurt.string.stringbuffer;

StringBuffer!(char) prodToString(typeof(TableItem.number) prod) {
	auto ret = new StringBuffer!(char)(1024);
	auto rule = parsetable.rules[prod];
	foreach(idx, it; rule) {
		ret.pushBack(idToString(it));
		if(idx == 0) {
			ret.pushBack(" :=");
		}
		ret.pushBack(' ');
	}
	return ret;
}

string tableitemToString(const TableItem ti) {
	auto ret = new StringBuffer!(char)(1024);
	final switch(ti.getTyp()) {
		case TableType.Accept:
			ret.pushBack("Accept: ");
			ret.pushBack(prodToString(ti.getNumber()));
			break;
		case TableType.Error:
			ret.pushBack("Error:");
			break;
		case TableType.Reduce:
			ret.pushBack("Reduce: ");
			ret.pushBack(prodToString(ti.getNumber()));
			break;
		case TableType.Goto:
			ret.pushBack("Goto:");
			break;
		case TableType.Shift:
			ret.pushBack("Shift: ");
			//assert(ti.getNumber() != 705);
			ret.pushBack("%d", ti.getNumber());
			break;
	}
	return ret.getString();
}
