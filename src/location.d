module location;

import hurt.string.formatter;

public struct Location {
	private string file;
	private size_t row;
	private size_t column;

	public this(string file, size_t row, size_t column) {
		this.file = file;
		this.row = row;
		this.column = column;
	}
	
	public string getFile() const {
		return this.file;
	}

	public size_t getRow() const {
		return this.row;
	}

	public size_t getColumn() const {
		return this.column;
	}

	public bool isDummyLoc() const {
		return (this.file is null || this.file == "") &&
			this.row == 0 || this.column == 0;
	}

	public string toString() const {
		return format("%s:%u:%u", this.file, this.row, this.column);
	}
}

