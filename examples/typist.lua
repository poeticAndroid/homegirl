scrn = createscreen(1, 2)

font = loadfont("./examples/fonts/Victoria.8b.gif")

function _init()
  setcolor(0, 0, 5, 10)
  setcolor(1, 15, 15, 15)
  setcolor(2, 0, 0, 2)
  setcolor(3, 15, 8, 0)
  bgcolor(0)
  fgcolor(1)
  copymode(2)
  setinputtext(
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
end

function _step(t)
  local txt = getinputtext()
  local pos = getinputpos()
  local sel = getinputselected()
  cls()
  fgcolor(1)
  text(txt, font, 0, 0)
  fgcolor(3)
  text(string.sub(txt, 0, pos) .. "\x7f", font, 0, 0)
  text(string.sub(txt, 0, pos + sel), font, 0, 0)
  if sel == 0 then
    fgcolor(2)
  else
    fgcolor(1)
  end
  text(string.sub(txt, 0, pos + 1), font, 0, 0)
  fgcolor(1)
  text(string.sub(txt, 0, pos), font, 0, 0)
end
