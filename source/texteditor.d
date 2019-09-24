module texteditor;

import std.array;
import std.utf;
import std.uni;
import std.algorithm;

/**
  headless text editor
*/
class TextEditor
{
  dstring text = ""; /// text content of the editor
  uint pos1 = 0; /// current character position of the main cursor
  uint pos2 = 0; /// current character position of the anchor cursor
  uint posBytes = 0; /// current byte position of the cursor
  uint selectedBytes = 0; /// number of bytes selected following current cursor position
  uint linesPerPage = 10; /// number of lines to move on PageUp/Dwn

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
    set cursor position in bytes
  */
  void setPosBytes(uint pos)
  {
    const left = this.getText().length;
    if (pos > left)
      pos = cast(uint) left;
    this.pos1 = cast(uint) toUTF32(this.getText()[0 .. pos]).length;
    this.pos2 = this.pos1;
    this.recalculate();
  }

  /**
    set selection length in bytes
  */
  void setSelectedBytes(uint sel)
  {
    const left = this.getText().length - this.posBytes;
    if (sel > left)
      sel = cast(uint) left;
    this.pos2 = min(this.pos1, this.pos2);
    this.pos1 = this.pos2 + cast(uint) toUTF32(
        this.getText()[this.posBytes .. this.posBytes + sel]).length;
    this.recalculate();
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
    return toUTF8(this.text[min(this.pos1, this.pos2) .. max(this.pos1, this.pos2)]);
  }

  /**
    recalculate posBytes and selectedBytes
  */
  void recalculate()
  {
    if (this.pos1 > this.text.length)
      this.pos1 = cast(uint) this.text.length;
    if (this.pos2 > this.text.length)
      this.pos2 = cast(uint) this.text.length;
    this.posBytes = cast(uint) toUTF8(this.text[0 .. min(this.pos1, this.pos2)]).length;
    this.selectedBytes = cast(uint) this.getSelectedText().length;
  }

  /**
    insert text at cursor
  */
  void insertText(string _text)
  {
    this.textHist ~= this.getText();
    this.posHist ~= this.pos1;
    if (this.textHist.length > 256)
    {
      this.textHist = this.textHist[1 .. $];
      this.posHist = this.posHist[1 .. $];
    }

    const text = toUTF32(replace(_text, "\r", ""));
    this.text = this.text[0 .. min(this.pos1, this.pos2)] ~ text ~ this.text[max(this.pos1,
        this.pos2) .. $];
    this.pos1 = min(this.pos1, this.pos2) + cast(uint) text.length;
    this.pos2 = this.pos1;
    this.recalculate();
  }

  /**
    delete character left of cursor
  */
  void backSpace(bool word = false)
  {
    if (this.pos1 == this.pos2 && this.pos1 > 0)
    {
      if (word)
        this.previousWord(true);
      else
        this.left(true);
    }
    this.insertText("");
  }

  /**
    delete character right of cursor
  */
  void deleteChar(bool word = false)
  {
    if (this.pos1 == this.pos2 && this.pos1 < this.text.length)
    {
      if (word)
        this.nextWord(true);
      else
        this.right(true);
    }
    this.insertText("");
  }

  /**
    move cursor right
  */
  void right(bool select = false)
  {
    if (this.pos1 >= this.text.length)
      return;
    const delta = toUTF8(this.text[this.pos1 .. this.pos1 + 1]).length;
    this.pos1++;
    if (this.pos1 <= this.pos2)
    {
      this.posBytes += delta;
      this.selectedBytes -= delta;
    }
    else
    {
      this.selectedBytes += delta;
    }
    if (!select)
    {
      if (this.pos1 > this.pos2)
        this.posBytes += this.selectedBytes;
      this.pos2 = this.pos1;
      this.selectedBytes = 0;
    }
  }

  /**
    move cursor left
  */
  void left(bool select = false)
  {
    if (this.pos1 <= 0)
      return;
    const delta = toUTF8(this.text[this.pos1 - 1 .. this.pos1]).length;
    this.pos1--;
    if (this.pos1 < this.pos2)
    {
      this.posBytes -= delta;
      this.selectedBytes += delta;
    }
    else
    {
      this.selectedBytes -= delta;
    }
    if (!select)
    {
      if (this.pos1 > this.pos2)
        this.posBytes += this.selectedBytes;
      this.pos2 = this.pos1;
      this.selectedBytes = 0;
    }
  }

  /**
    move cursor down
  */
  void down(bool select = false)
  {
    uint col = 0;
    while (this.pos1 > 0 && this.text[this.pos1 - 1] != 10)
    {
      this.left(select);
      col++;
    }
    while (this.pos1 < this.text.length && this.text[this.pos1] != 10)
      this.right(select);
    if (this.pos1 < this.text.length)
      this.right(select);
    while (col-- && this.pos1 < this.text.length && this.text[this.pos1] != 10)
      this.right(select);
  }

  /**
    move cursor up
  */
  void up(bool select = false)
  {
    uint col = 0;
    while (this.pos1 > 0 && this.text[this.pos1 - 1] != 10)
    {
      this.left(select);
      col++;
    }
    if (this.pos1 > 0)
      this.left(select);
    while (this.pos1 > 0 && this.text[this.pos1 - 1] != 10)
      this.left(select);
    while (col-- && this.pos1 < this.text.length && this.text[this.pos1] != 10)
      this.right(select);
  }

  /**
    move cursor down one page
  */
  void pageDown(bool select = false)
  {
    for (uint i = 0; i < this.linesPerPage; i++)
      this.down(select);
  }

  /**
    move cursor up one page
  */
  void pageUp(bool select = false)
  {
    for (uint i = 0; i < this.linesPerPage; i++)
      this.up(select);
  }

  /**
    move cursor to next word
  */
  void nextWord(bool select = false)
  {
    if (this.pos1 >= this.text.length)
      return;
    uint type = this.charType(this.text[this.pos1]);
    while (this.pos1 < this.text.length && type == this.charType(this.text[this.pos1]))
      this.right(select);
  }

  /**
    move cursor to previous word
  */
  void previousWord(bool select = false)
  {
    if (this.pos1 <= 0)
      return;
    uint type = this.charType(this.text[this.pos1 - 1]);
    while (this.pos1 > 0 && type == this.charType(this.text[this.pos1 - 1]))
      this.left(select);
  }

  /**
    move cursor to beginning of current line
  */
  void home(bool select = false)
  {
    while (this.pos1 > 0 && this.text[this.pos1 - 1] != 10)
      this.left(select);
  }

  /**
    move cursor to end of current line
  */
  void end(bool select = false)
  {
    while (this.pos1 < this.text.length && this.text[this.pos1] != 10)
      this.right(select);
  }

  /**
    move cursor to the beginning of the document
  */
  void docStart(bool select = false)
  {
    this.pos1 = 0;
    if (!select)
      this.pos2 = this.pos1;
    this.recalculate();
  }

  /**
    move cursor to the end of the document
  */
  void docEnd(bool select = false)
  {
    this.pos1 = cast(uint) this.text.length;
    if (!select)
      this.pos2 = this.pos1;
    this.recalculate();
  }

  /**
    indent current line according to the previous line
  */
  void indent()
  {
    this.home();
    this.up();
    string ind = "";
    uint p = this.pos1;
    while (p < this.text.length && this.text[p] != 10 && this.text[p] < 33)
      ind ~= this.text[p++];
    this.down();
    this.insertText(ind);
  }

  /**
    detect type of indentation used in the document
  */
  string detectIndentation()
  {
    auto i = countUntil(this.text, "\n\t");
    if (i > 0)
    {
      return "\t";
    }
    else
    {
      string ind = " ";
      auto j = countUntil(this.text, "\n" ~ ind ~ " ");
      if (j < 0)
        return "\t";
      do
      {
        ind ~= " ";
        i = countUntil(this.text, "\n" ~ ind ~ " ");
      }
      while (i == j);
      return ind;
    }
  }

  /**
    select all text
  */
  void selectAll()
  {
    this.pos1 = cast(uint) this.text.length;
    this.pos2 = 0;
    this.posBytes = 0;
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
    this.pos1 = this.posHist[last];
    this.pos2 = this.posHist[last];
    this.posHist = this.posHist[0 .. last];
    this.recalculate();
  }

  /**
    Clear undo history
  */
  void clearHistory()
  {
    if (this.textHist.length == 0)
      return;
    this.textHist = [];
    this.posHist = [];
  }

  // -- _privates -- //
  uint charType(dchar chr)
  {
    if (isAlpha(chr))
      return 1;
    if (isNumber(chr))
      return 2;
    return 0;
  }
}
