class CodeBuilder extends StringBuffer {
  int _indentationLevel = 0;

  void applyTabs() {
    for (int i = 0; i < _indentationLevel; i++) super.write("  ");
  }

  void indent() {
    if (_indentationLevel < 0)
      _indentationLevel = 1;
    else
      _indentationLevel++;
  }

  void outdent() {
    _indentationLevel--;
  }

  void put(Object object) {
    applyTabs();
    super.write(object);
  }

  void putln([Object object]) {
    super.writeln(object);
  }

  @override
  void write(Object object) {
    applyTabs();
    super.write(object);
  }

  @override
  void writeln([Object object]) {
    applyTabs();
    super.writeln(object);
  }

  void resetIndentation() {
    _indentationLevel = 0;
  }
}
