screendrag = require("./screendrag")

scrn = view.newscreen(11, 2)

font = text.loadfont("./fonts/Victoria.8b.gif")

function _init()
  gfx.palette(0, 0, 5, 10)
  gfx.palette(1, 15, 15, 15)
  gfx.palette(2, 0, 0, 2)
  gfx.palette(3, 15, 8, 0)
  gfx.bgcolor(0)
  gfx.fgcolor(1)
  input.text(
    [[Når jeg står ved min maskine på min dejlige fabrik
Så er jeg glad for at leve, det' da klart - er det ikk'?
Mine hænder er bløde som en anden funktionærs
Og jeg har masser af tid til min børne-krydsogtværs

Imens det siger "blip-båt", og gud, hvor går det godt
Vi har, hva' vi ska' ha' af både stort og småt
Ja, blip-båt, og gud, hvor går det godt
Vi har, hva' vi ska' ha' af både stort og småt

Muzakken, som de spiller, synes jeg, er skide go'
Når jeg stamper med på rytmen, så knirker mine sko
Og nede for enden af den lange lyse hal
Ka' jeg se det store ur med de magiske tal

Det siger "blip-båt", og gud, hvor går det godt
Vi har, hva' vi ska' ha' af både stort og småt
Blip-båt, og gud, hvor går det godt
Vi har, hva' vi ska' ha' af både stort og småt]]
  )
  input.cursor(0)
  input.selected(3)
end

function _step(t)
  local txt = input.text()
  local pos = input.cursor()
  local sel = input.selected()
  gfx.cls()
  gfx.fgcolor(1)
  text.draw(txt, font, 0, 0)
  gfx.fgcolor(3)
  text.draw(string.sub(txt, 0, pos) .. "\x7f", font, 0, 0)
  text.draw(string.sub(txt, 0, pos + sel), font, 0, 0)
  if sel == 0 then
    gfx.fgcolor(2)
  else
    gfx.fgcolor(1)
  end
  text.draw(string.sub(txt, 0, pos + 1), font, 0, 0)
  gfx.fgcolor(1)
  text.draw(string.sub(txt, 0, pos), font, 0, 0)
  screendrag.step(scrn)
end
