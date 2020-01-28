local Widget = require("widget")

local Menu = Widget:extend()
do
  function Menu:constructor(struct)
    self.struct = {
      menu = struct
    }
    self.active = false
    self:_gethotkeys()
  end

  function Menu:attachto(parent, parentvp, screen)
    self.parent = parent
    self.parentvp = parentvp or parent.mainvp or parent.container
    self.screen = screen or parent.screen
  end
  function Menu:destroy()
    self:close()
    if self._prevstepint and sys.stepinterval() == -2 then
      sys.stepinterval(self._prevstepint)
    end
  end

  function Menu:step(t)
    local prevvp = view.active()
    view.active(self.parentvp)
    local mx, my, mb = input.mouse()
    if self.active then
      mb = math.min(2, mb * 2)
      if not view.focused(self.parentvp) and self._mb == 0 then
        mb = 2
      end
    end
    if self._mb == 2 and mb == 0 then
      self.active = not self.active
      if self.active then
        self._prevstepint = nil
        if sys.stepinterval() == -1 then
          self._prevstepint = sys.stepinterval()
          sys.stepinterval(-2)
        end
      else
        self:close()
        if self._prevstepint and math.abs(sys.stepinterval()) == 2 then
          sys.stepinterval(self._prevstepint)
        end
      end
    end
    local hk = input.hotkey()
    if self._hotkeys[hk] then
      self._selected = self._hotkeys[hk]
    end
    if self.active then
      self:open()
      view.focused(self.parentvp, true)
    elseif self._selected then
      if self._selected.action then
        self._selected.action(self._selected)
      end
      self._selected = nil
    end
    self._mb = mb
    view.active(prevvp)
  end

  function Menu:open(struct, ml, mt)
    local prevvp = view.active()
    local sw, sh = view.size(self.screen)
    local topmenu = false
    local mw, mh, tw, th = 0, 0, 0, 0
    if not struct then
      topmenu = true
      struct = self.struct
    end
    if not struct.vp then
      struct.vp = view.new(self.screen, ml, mt)
    end
    ml, mt = view.position(struct.vp)
    view.active(struct.vp)
    local tl = 0
    for i, menu in ipairs(struct.menu) do
      tw, th = text.draw(self:_label(menu, topmenu), self.font)
      if not topmenu then
        tl = math.max(tl, #(menu.label))
      end
      if topmenu then
        mw = sw
      else
        mh = mh + th
      end
      if mw < tw then
        mw = tw
      end
      if mh < th then
        mh = th
      end
    end
    mw = mw + 2
    mh = mh + 2
    view.size(struct.vp, mw, mh)
    if not topmenu then
      if ml + mw > sw then
        ml, mt = 0, sh - mh - 1
      end
      if mt + mh > sh then
        mt = sh - mh - 1
      end
    end
    view.position(struct.vp, ml, mt)
    gfx.bgcolor(self.lightcolor)
    gfx.cls()
    local mx, my, mb = input.mouse()
    local inside = false
    if mx >= 0 and my >= 0 and mx < mw and my < mh then
      inside = true
    end
    local x = topmenu and 3 or 0
    local y = topmenu and 0 or 1
    for i, menu in ipairs(struct.menu) do
      if inside then
        if topmenu then
          tw, th = text.draw(self:_label(menu, topmenu), self.font, mw, mh)
          if mx >= x and mx < x + tw then
            menu.active = true
            if mb > 0 then
              self._selected = menu
            end
          else
            menu.active = false
          end
        else
          if my >= y and my < y + th then
            menu.active = true
            if mb > 0 then
              self._selected = menu
            end
          else
            menu.active = false
          end
        end
      end
      if menu.active and menu.menu then
        if topmenu then
          self:open(menu, x, th + 1)
        else
          self:open(menu, ml + mw - 4, mt + y - 1)
        end
      else
        self:close(menu)
      end
      while #(menu.label) < tl do
        menu.label = menu.label .. " "
      end
      gfx.fgcolor(menu.active and self.fgcolor or self.lightcolor)
      gfx.bar(x, y, mw, mh)
      gfx.fgcolor(menu.active and self.fgtextcolor or self.darkcolor)
      tw, th = text.draw(self:_label(menu, topmenu), self.font, x, y + (topmenu and 1 or 0))
      if topmenu then
        x = x + tw
      else
        y = y + th
      end
    end
    gfx.fgcolor(self.lightcolor)
    gfx.bar(x, y, mw, mh)
    if not topmenu then
      gfx.fgcolor(self.darkcolor)
      gfx.bar(0, 0, mw, 1)
      gfx.bar(0, mh - 1, mw, 1)
      gfx.bar(0, 0, 1, mh)
      gfx.bar(mw - 1, 0, 1, mh)
    end
    view.active(prevvp)
  end
  function Menu:close(struct)
    if not struct then
      struct = self.struct
    end
    if struct.vp then
      for i, menu in ipairs(struct.menu) do
        self:close(menu)
      end
      view.remove(struct.vp)
      struct.vp = nil
    end
  end

  function Menu:_label(struct, top)
    if top then
      return " " .. struct.label .. " "
    else
      return (struct.checked and " *" or "  ") ..
        struct.label .. (struct.menu and "  >" or (struct.hotkey and (" ^" .. struct.hotkey) or "   "))
    end
  end

  function Menu:_gethotkeys(struct)
    if not struct then
      struct = self.struct
      self._hotkeys = {}
    end
    if struct.hotkey then
      self._hotkeys[struct.hotkey] = struct
    end
    if struct.menu then
      for i, menu in ipairs(struct.menu) do
        self:_gethotkeys(menu)
      end
    end
  end
end
return Menu
