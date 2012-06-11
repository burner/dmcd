module symtabattributes;

import hurt.string.stringbuffer;
import hurt.container.deque;

enum Attributes : uint {
	aPublic,
	aPrivate,
	aProtected,
	aPackage,
	aSafe,
	aTrusted,
	aSytem,
	aNoThrow,
	aExport,
	aAlign,
	aPure,
	aConst,
	aImmutable,
	aInOut,
	aShared,
	aDeprecated,
	aStatic,
	aExtern,
	aFinal,
	aSyncronized,
	aOverride,
	aAbstract,
	aAuto,
	aGShared,
	aDisable
}

private static immutable auto attributesNames = 
	__traits(allMembers, Attributes);

private static Deque!(string) attributesNamesAccess;

static this() {
	attributesNamesAccess = new Deque!(string)(32);
	foreach(it; attributesNames) {
		attributesNamesAccess.pushBack(it[1 .. $]);
	}
}

@safe pure void setAttribute(ref uint attrValue, Attributes attr, 
		bool value = true) {
	if(value) {	
		uint toSet = 1u << attr;	
		attrValue |= toSet;
	} else {
		uint toSet = ~(1u << attr);
		attrValue &= toSet;
	}
}

@safe pure bool hasAttribute(uint attrValue, Attributes attr) {
	uint toSet = 1u << attr;
	return (attrValue & toSet) != 0;
}

string attributesToString(uint attrValue) {
	auto ret = new StringBuffer!(char)(128);
	for(uint i = 0; i <= attributesNames.length; i++) {
		if(hasAttribute(attrValue, cast(Attributes)i)) {
			ret.pushBack(attributesNamesAccess[i]);
			ret.pushBack(',');
		}
	}
	if(ret.getSize() > 0) {
		ret.popBack();
	}
	return ret.getString();
}

unittest {
	uint attrValue;
	setAttribute(attrValue, Attributes.aStatic, true);
	assert(hasAttribute(attrValue, Attributes.aStatic));
	assert(attributesToString(attrValue) == "Static", 
		attributesToString(attrValue));
	setAttribute(attrValue, Attributes.aDisable, true);
	assert(hasAttribute(attrValue, Attributes.aStatic));
	assert(hasAttribute(attrValue, Attributes.aDisable));
	setAttribute(attrValue, Attributes.aPublic);
	assert(hasAttribute(attrValue, Attributes.aStatic));
	assert(hasAttribute(attrValue, Attributes.aDisable));
	assert(hasAttribute(attrValue, Attributes.aPublic));
	setAttribute(attrValue, Attributes.aDisable, false);
	assert(hasAttribute(attrValue, Attributes.aStatic));
	assert(!hasAttribute(attrValue, Attributes.aDisable));
	assert(hasAttribute(attrValue, Attributes.aPublic));
	/*assert(attributesToString(attrValue) == "Public,Static", 
		attributesToString(attrValue));*/
}

