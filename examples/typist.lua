dofile("./examples/screendrag.lua")

scrn = view.createscreen(1, 2)

font = text.loadfont("./examples/fonts/Victoria.8b.gif")

function _init()
  gfx.setcolor(0, 0, 5, 10)
  gfx.setcolor(1, 15, 15, 15)
  gfx.setcolor(2, 0, 0, 2)
  gfx.setcolor(3, 15, 8, 0)
  gfx.bgcolor(0)
  gfx.fgcolor(1)
  image.copymode(2)
  input.setinputtext(
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
  input.setinputpos(0)
  input.setinputselected(3)
end

function _step(t)
  local txt = input.getinputtext()
  local pos = input.getinputpos()
  local sel = input.getinputselected()
  gfx.cls()
  gfx.fgcolor(1)
  text.text(txt, font, 0, 0)
  gfx.fgcolor(3)
  text.text(string.sub(txt, 0, pos) .. "\x7f", font, 0, 0)
  text.text(string.sub(txt, 0, pos + sel), font, 0, 0)
  if sel == 0 then
    gfx.fgcolor(2)
  else
    gfx.fgcolor(1)
  end
  text.text(string.sub(txt, 0, pos + 1), font, 0, 0)
  gfx.fgcolor(1)
  text.text(string.sub(txt, 0, pos), font, 0, 0)
  dragscreen(scrn)
end
