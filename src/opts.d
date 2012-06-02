module opts;

import hurt.exception.exception;
import hurt.string.formatter;
import hurt.container.set;
import hurt.container.isr;
import hurt.conv.conv;

pure:
public struct Opt {
	public:
	bool lpMulti = true;
	int numToken = 10;
	Set!(size_t) marked;
	string[] saved;

	Opt opCall(string[] args) {
		return Opt(args);
	}

	this(string[] args) {
		this.marked = new Set!(size_t)(ISRType.HashTable);
		this.saved = args;
		foreach(size_t idx, string it; args) {
			if(it == "-l" || it == "--lpMulti") {
				this.marked .insert(idx);
				if(idx+1 == args.length) {
					this.lpMulti = true;
				} else if(args[idx+1] == "false") {
					this.marked .insert(idx+1);
					this.lpMulti = false;
				} else if(args[idx+1] == "true") {
					this.marked .insert(idx+1);
					this.lpMulti = true;
				} else {
					this.lpMulti = true;
				}
				continue;
			} else if(it == "-t" || it == "--token") {
				enforce(idx+1 < args.length, format(
					"an integer must follow %s at position %d", it, idx));
				enforce(convsTo!int(args[idx+1]), format(
					"(%s) can't convert to integer", args[idx+1]));

				this.marked .insert(idx+1);
				this.numToken = conv!(string,int)(args[idx+1]);
			}
		}
	}

	public int opApply(int delegate(ref string) dg) {
		foreach(idx, it; this.saved) {
			if(this.marked.contains(idx)) {
				continue;
			}
			string dT = it;
			if(int r = dg(dT)) {
				return r;
			}
		}
		return 0;
	}

}

	
