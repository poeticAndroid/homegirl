module texteditor;

import std.array;
import std.utf;

/**
  headless text editor
*/
class TextEditor
{
  dstring text = ""; /// text content of the editor
  uint pos = 0; /// current character position of the cursor
  uint posBytes = 0; /// current byte position of the cursor
  uint line = 1; /// current line of the cursor
  uint col = 0; /// current column of the cursor
  uint selected = 0; /// number of characters selected following current cursor position
  uint selectedBytes = 0; /// number of bytes selected following current cursor position

  string[] textHist; /// history of latest text changes
  uint[] posHist; /// history of cursor positions at latest text changes

  /**
    set text content of editor
  */
  void setText(string text)
  {
    this.selectAll();
    this.insertText(text);
  }

  /**
    get text content of editor
  */
  string getText()
  {
    return toUTF8(this.text);
  }

  /**
    get selected text
  */
  string getSelectedText()
  {
    return toUTF8(this.text[this.pos .. this.pos + this.selected]);
  }

  /**
    recalculate line and column
  */
  void recalculate()
  {
    this.line = 1;
    this.col = 0;
    if (this.pos > this.text.length)
      this.pos = cast(uint) this.text.length;
    if (this.pos + this.selected > this.text.length)
      this.selected = cast(uint) this.text.length - this.pos;
    for (uint i = 0; i < this.pos; i++)
    {
      this.col++;
      if (this.text[i] == 10)
      {
        this.line++;
        this.col = 0;
      }
    }
    this.posBytes = cast(uint) toUTF8(this.text[0 .. this.pos]).length;
    this.selectedBytes = cast(uint) this.getSelectedText().length;
  }

  /**
    insert text at cursor
  */
  void insertText(string _text)
  {
    this.textHist ~= this.getText();
    this.posHist ~= this.pos;
    if (this.textHist.length > 256)
    {
      this.textHist = this.textHist[1 .. this.textHist.length];
      this.posHist = this.posHist[1 .. this.posHist.length];
    }

    const text = toUTF32(replace(_text, "\r", ""));
    this.text = this.text[0 .. this.pos] ~ text
      ~ this.text[this.pos + this.selected .. this.text.length];
    this.pos += text.length;
    this.selected = 0;
    this.recalculate();
  }

  /**
    delete character left of cursor
  */
  void backSpace()
  {
    if (this.selected == 0 && this.pos > 0)
    {
      this.pos--;
      this.selected++;
    }
    this.insertText("");
  }

  /**
    delete character right of cursor
  */
  void deleteChar()
  {
    if (this.selected == 0 && this.pos < this.text.length)
      this.selected++;
    this.insertText("");
  }

  /**
    move cursor right
  */
  void right(bool select = false)
  {
    if (select)
    {
      if (this.pos + this.selected < this.text.length)
        this.selected++;
      this.selectedBytes = cast(uint) this.getSelectedText().length;
      return;
    }
    this.selected = 0;
    this.selectedBytes = 0;
    if (this.pos >= this.text.length)
      return;
    this.col++;
    if (this.text[this.pos] == 10)
    {
      this.line++;
      this.col = 0;
    }
    this.posBytes += toUTF8(this.text[this.pos .. this.pos + 1]).length;
    this.pos++;
  }

  /**
    move cursor left
  */
  void left(bool select = false)
  {
    if (!select)
    {
      this.selected = 0;
      this.selectedBytes = 0;
    }
    if (this.pos == 0)
      return;
    this.col--;
    this.pos--;
    this.posBytes -= toUTF8(this.text[this.pos .. this.pos + 1]).length;
    if (this.text[this.pos] == 10)
      this.recalculate();
    if (select)
    {
      this.selected++;
      this.selectedBytes = cast(uint) this.getSelectedText().length;
    }
  }

  /**
    move cursor down
  */
  void down(bool select = false)
  {
    uint _pos = this.pos;
    this.pos += this.selected;
    if (this.pos >= this.text.length)
    {
      this.pos = _pos;
      return;
    }
    if (this.selected)
      this.recalculate();
    const targetLine = this.line + 1;
    const targetCol = this.col;
    while (this.pos < this.text.length && this.line < targetLine)
      this.right();
    while (this.pos < this.text.length && this.line == targetLine && this.col < targetCol)
      this.right();
    while (this.pos > 0 && this.line > targetLine)
      this.left();
    if (select)
    {
      this.selected = this.pos - _pos;
      this.pos = _pos;
      this.recalculate();
    }
  }

  /**
    move cursor up
  */
  void up(bool select = false)
  {
    uint _pos = this.pos + this.selected;
    if (!select)
      this.selected = 0;
    if (this.pos == 0)
      return;
    const targetLine = this.line - 1;
    const targetCol = this.col;
    while (this.pos > 0 && this.line > targetLine)
      this.left();
    while (this.pos > 0 && this.line == targetLine && this.col > targetCol)
      this.left();
    while (this.pos < this.text.length && this.line < targetLine)
      this.right();
    if (select)
      this.selected += _pos - this.pos;
    this.selectedBytes = cast(uint) this.getSelectedText().length;
  }

  /**
    move cursor to beginning of current line
  */
  void home(bool select = false)
  {
    this.left(select);
    while (this.pos > 0 && this.text[this.pos] != 10)
      this.left(select);
    if (this.pos > 0)
      this.right(select);
  }

  /**
    move cursor to end of current line
  */
  void end(bool select = false)
  {
    uint _pos = this.pos;
    this.pos += this.selected;
    while (this.pos < this.text.length && this.text[this.pos] != 10)
      this.right();
    if (select)
    {
      this.selected = this.pos - _pos;
      this.pos = _pos;
      this.recalculate();
    }
  }

  /**
    select all text
  */
  void selectAll()
  {
    this.pos = 0;
    this.posBytes = 0;
    this.line = 1;
    this.col = 0;
    this.selected = cast(uint) this.text.length;
    this.selectedBytes = cast(uint) this.getText().length;
  }

  /**
    Undo last change
  */
  void undo()
  {
    if (this.textHist.length == 0)
      return;
    uint last = cast(uint) this.textHist.length - 1;
    this.setText(this.textHist[last]);
    this.textHist = this.textHist[0 .. last];
    this.pos = this.posHist[last];
    this.posHist = this.posHist[0 .. last];
    this.recalculate();
  }
}
