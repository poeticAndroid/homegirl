module viewport;

import std.algorithm.searching;
import std.algorithm.mutation;
import pixmap;
import program;
import texteditor;

/**
  Class representing a viewport
*/
class Viewport
{
  ubyte mode; /// screen mode
  Pixmap pixmap; /// pixmap of the viewport
  int left; /// position of left side of viewport relative to parent
  int top; /// position of top of viewport relative to parent
  bool visible = true; /// whether this viewport will be rendered or not
  Program program; /// the program that owns this viewport
  int mouseX; /// X position of the mouse relative to this viewport
  int mouseY; /// Y position of the mouse relative to this viewport
  ubyte mouseBtn; /// Mouse button state if this viewport has focus
  char hotkey; /// hotkey just pressed if this viewport has focus
  ubyte[2] gameBtn; /// Game state for each player if this viewport has focus
  TextEditor textinput; /// text editor
  Basket basket; /// drop basket for drag-and-drop
  string[string] attributes; /// attributes
  Pixmap pointer; /// mouse pointer
  int pointerX; /// mouse pointer anchor
  int pointerY; /// mouse pointer anchor
  bool dirty = true; /// whether this viewport needs to be rerendered;

  /**
    create a new Viewport
  */
  this(Viewport parent, int left, int top, uint width, uint height, ubyte colorBits)
  {
    this.parent = parent;
    this.left = left;
    this.top = top;
    this.pixmap = new Pixmap(width, height, colorBits);
    this.pixmap.viewport = this;
  }

  /**
    calculate memory usage of this pixmap
  */
  uint memoryUsed()
  {
    return this.pixmap.memoryUsed();
  }

  Viewport getParent()
  {
    return this.parent;
  }

  /**
    Detach this viewport from parent
  */
  void detach()
  {
    this.pixmap.destroyTexture();
    if (this.parent)
    {
      auto parent = this.parent;
      this.parent = null;
      parent.removeViewport(this);
    }
    if (this.program)
    {
      this.program = null;
    }
  }

  /**
    create a new viewport inside this one
  */
  Viewport createViewport(int left, int top, uint width, uint height)
  {
    Viewport vp = new Viewport(this, left, top, width, height, this.pixmap.colorBits);
    this.children ~= vp;
    return vp;
  }

  /**
    remove a child viewport from this one
  */
  void removeViewport(Viewport vp)
  {
    auto i = countUntil(this.children, vp);
    if (i != -1)
    {
      this.children = this.children.remove(i);
      vp.detach();
    }
    this.setDirty();
  }

  /**
    get a child viewport by its z-index
  */
  Viewport[] getChildren()
  {
    return this.children;
  }

  /**
    get z-index of a child viewport
  */
  int getViewportIndex(Viewport vp)
  {
    return cast(int) countUntil(this.children, vp);
  }

  /**
    set z-index of a child viewport
  */
  void setViewportIndex(Viewport vp, int index)
  {
    auto i = countUntil(this.children, vp);
    if (i < 0)
      return;
    while (index < 0)
      index += this.children.length;
    if (index >= this.children.length)
      index = cast(int) this.children.length - 1;
    this.children = this.children.remove(i);
    this.children = this.children[0 .. index] ~ vp ~ this.children[index .. $];
  }

  /**
    check to see if this viewport is visible
  */
  bool isVisible()
  {
    if (this.visible && this.parent)
      return this.parent.isVisible();
    return this.visible;
  }

  /**
    check if this viewport is (in) given viewport
  */
  bool isInViewport(Viewport vp)
  {
    if (this == vp)
      return true;
    else if (this.parent)
      return this.parent.isInViewport(vp);
    else
      return false;
  }

  /**
    Check if this viewport contains/is given viewport
  */
  bool containsViewport(Viewport vp)
  {
    if (vp)
      return vp.isInViewport(this);
    else
      return false;
  }

  /**
    get deepest viewport of frontmost branch
  */
  Viewport getFrontBranch()
  {
    if (!this.children.length)
      return this;
    return this.children[$ - 1].getFrontBranch();
  }

  /**
    move this viewport
  */
  void move(int left, int top)
  {
    if (this.left != left || this.top != top)
    {
      this.left = left;
      this.top = top;
      if (this.parent)
        this.parent.setDirty();
    }
  }

  /**
    resize this viewport
  */
  void resize(uint width, uint height)
  {
    if (this.pixmap.width != width || this.pixmap.height != height)
    {
      if (this.program)
        this.program.freeMemory(this.memoryUsed());
      this.pixmap.destroyTexture();
      this.pixmap = new Pixmap(width, height, this.pixmap.colorBits);
      this.pixmap.viewport = this;
      this.setDirty();
      if (this.program)
        this.program.useMemory(this.memoryUsed());
    }
  }

  /**
    change screen mode
  */
  void changeMode(ubyte mode, ubyte colorBits)
  {
    this.parent.changeMode(mode, colorBits);
  }

  /**
    set mouse position and return which viewport is pointed on
  */
  Viewport setMouseXY(int x, int y)
  {
    this.mouseX = x;
    this.mouseY = y;
    Viewport vp = this;
    foreach (viewport; this.children)
    {
      if (viewport && viewport.visible)
      {
        Viewport _vp = viewport.setMouseXY(x - viewport.left, y - viewport.top);
        if (_vp)
          vp = _vp;
      }
    }
    if (x >= 0 && x < this.pixmap.width && y >= 0 && y < this.pixmap.height)
      return vp;
    else
      return null;
  }

  /**
    set mouse button for this and all parent viewports
  */
  void setMouseBtn(ubyte btn)
  {
    this.mouseBtn = btn;
    if (this.parent)
      this.parent.setMouseBtn(btn);
  }

  /**
    set hotkey for this and all parent viewports
  */
  void setHotkey(char key)
  {
    this.hotkey = key;
    if (this.parent)
      this.parent.setHotkey(key);
  }

  /**
    set game state for this and all parent viewports
  */
  void setGameBtn(ubyte state, ubyte player)
  {
    if (!player)
      return;
    this.gameBtn[player - 1] = state;
    if (this.parent)
      this.parent.setGameBtn(state, player);
  }

  /**
    get game state for this viewport
  */
  ubyte getGameBtn(ubyte player)
  {
    if (player)
      return this.gameBtn[player - 1];
    else
    {
      ubyte btn = 0;
      for (uint i = 0; i < this.gameBtn.length; i++)
        btn |= this.gameBtn[i];
      return btn;
    }
  }

  /**
    get text input for this viewport
  */
  TextEditor getTextinput(bool create = false)
  {
    if (!this.textinput)
    {
      if (create)
        this.textinput = new TextEditor();
      else if (this.parent)
        return this.parent.getTextinput(create);
    }
    return this.textinput;
  }

  /**
    get drop basket for this viewport
  */
  Basket getBasket(bool create = false)
  {
    if (!this.basket)
    {
      if (create)
        this.basket = new Basket();
      else if (this.parent)
        return this.parent.getBasket(create);
    }
    return this.basket;
  }

  /**
    clear inputs
  */
  void clearInput()
  {
    this.mouseBtn = 0;
    this.hotkey = 0;
    for (ubyte i = 0; i < this.gameBtn.length; i++)
      this.gameBtn[i] = 0;
  }

  /**
    set this viewport as being dirty
  */
  void setDirty()
  {
    this.dirty = true;
    if (this.parent)
      this.parent.setDirty();
  }

  /**
    Render any visible children onto this viewport
  */
  void render()
  {
    this.visible = true;
    if (!this.dirty)
      return;
    foreach (viewport; this.children)
    {
      if (viewport && viewport.visible)
      {
        if (this.mode != viewport.mode)
          viewport.mode = this.mode;
        if (this.pixmap.colorBits != viewport.pixmap.colorBits)
        {
          if (viewport.program)
            viewport.program.freeMemory(viewport.memoryUsed());
          viewport.pixmap.destroyTexture();
          Pixmap oldpix = viewport.pixmap;
          viewport.pixmap = new Pixmap(oldpix.width, oldpix.height, this.pixmap.colorBits);
          viewport.pixmap.viewport = viewport;
          viewport.pixmap.copyRectFrom(oldpix, 0, 0, 0, 0, oldpix.width, oldpix.height);
          viewport.pixmap.setFGColor(oldpix.fgColor);
          viewport.pixmap.setBGColor(oldpix.bgColor);
          viewport.pixmap.copymode = oldpix.copymode;
          viewport.pixmap.textCopymode = oldpix.textCopymode;
          if (viewport.program)
            viewport.program.useMemory(viewport.memoryUsed());
        }
        viewport.render();
        this.pixmap.copyRectFrom(viewport.pixmap, 0, 0, viewport.left,
            viewport.top, viewport.pixmap.width, viewport.pixmap.height);
      }
    }
    this.dirty = false;
  }

  // -- _privates -- //
  private Viewport parent; /// parent of this viewport
  private Viewport[] children; /// children of this viewport
  // private uint nextVPid = 0;
}

/**
  basket for catching drops
*/
class Basket
{
  string[] drops;

  this()
  {
    this.drops = [];
  }

  void deposit(string[] drops)
  {
    this.drops ~= drops;
  }

  string dispense()
  {
    if (this.drops.length == 0)
      return null;
    string drop = this.drops[0];
    this.drops = this.drops.remove(0);
    return drop;
  }
}
