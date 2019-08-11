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
  TextEditor textinput; ///text editor

  /**
    create a new Viewport
  */
  this(Viewport parent, int left, int top, uint width, uint height, ubyte colorBits)
  {
    this.parent = parent;
    this.left = left;
    this.top = top;
    this.pixmap = new Pixmap(width, height, colorBits);
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
  }

  /**
    send child to back
  */
  void sendViewportToBack(Viewport vp)
  {
    auto i = countUntil(this.children, vp);
    if (i != -1)
      this.children = [vp] ~ this.children.remove(i);
  }

  /**
    bring child to front
  */
  void bringViewportToFront(Viewport vp)
  {
    auto i = countUntil(this.children, vp);
    if (i != -1)
      this.children = this.children.remove(i) ~ [vp];
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
    move this viewport
  */
  void move(int left, int top)
  {
    this.left = left;
    this.top = top;
  }

  /**
    resize this viewport
  */
  void resize(uint width, uint height)
  {
    this.pixmap.destroyTexture();
    this.pixmap = new Pixmap(width, height, this.pixmap.colorBits);
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
  TextEditor getTextinput()
  {
    if (!this.textinput)
      this.textinput = new TextEditor();
    return this.textinput;
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
    Render any visible children onto this viewport
  */
  void render()
  {
    foreach (viewport; this.children)
    {
      if (viewport && viewport.visible)
      {
        if (this.pixmap.colorBits != viewport.pixmap.colorBits)
        {
          viewport.pixmap.destroyTexture();
          viewport.pixmap = new Pixmap(viewport.pixmap.width,
              viewport.pixmap.height, this.pixmap.colorBits);
        }
        viewport.render();
        this.pixmap.copyFrom(viewport.pixmap, 0, 0, viewport.left,
            viewport.top, viewport.pixmap.width, viewport.pixmap.height);
      }
    }
  }

  // -- _privates -- //
  private Viewport parent; /// parent of this viewport
  private Viewport[] children; /// children of this viewport
  // private uint nextVPid = 0;
}
