module viewport;

import std.algorithm.searching;
import std.algorithm.mutation;
import pixmap;
import program;

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
    Viewport vp = new Viewport(this, left, top, width, height, 0);
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
    check if this viewport is (in) given viewport
  */
  bool isInViewport(Viewport vp)
  {
    Viewport parent = this;
    while (parent)
    {
      if (parent == vp)
      {
        return true;
      }
      parent = parent.getParent();
    }
    return false;
  }

  /**
    Check if this viewport contains/is given viewport
  */
  bool containsViewport(Viewport vp)
  {
    return vp.isInViewport(this);
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
    Render any children onto this viewport
  */
  void render()
  {
    foreach (viewport; this.children)
    {
      if (viewport.visible)
      {
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
