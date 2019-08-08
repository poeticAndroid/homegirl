f0 = 440
fa = math.pow(2, 1 / 12)

function tone2freq(tone)
  return f0 * math.pow(fa, tone)
end

square = audio.new()
function _init()
  len = 8
  audio.samplelength(square, len)
  while len > 0 do
    len = len - 1
    val = 15
    if len < 4 then
      val = -16
    end
    audio.samplevalue(square, len, val)
  end
  audio.sampleloop(square, 0, 8)
  start, endd = audio.sampleloop(square)
  for chan = 0, 3 do
    audio.play(chan, square)
  end
  sys.stepinterval(200)
end

vol = 63
pos = 1
achan = 0
dchan = 1
function _step(t)
  for chan = 0, 3 do
    audio.channelfreq(chan, tone2freq(song[pos]))
  end
  if song[pos] ~= song[pos - 1] then
    vol = 63
  end
  for chan = 0, 3 do
    audio.channelvolume(chan, 0)
  end
  audio.channelvolume(achan, vol)
  achan = achan + dchan
  if achan == 0 then
    dchan = 1
  end
  if achan == 3 then
    dchan = -1
  end
  if vol > 0 then
    vol = vol - 10
  end
  pos = pos + 1
end

song = {
  27,
  27,
  27,
  24,
  24,
  24,
  20,
  20,
  20,
  15,
  15,
  15, -- Daisy, Daisy,
  17,
  19,
  20,
  17,
  17,
  20,
  15,
  15,
  15,
  15,
  15,
  15, -- Give me your answer, do!
  22,
  22,
  22,
  27,
  27,
  27,
  24,
  24,
  24,
  20,
  20,
  20, -- I'm half crazy,
  17,
  19,
  20,
  22,
  22,
  24,
  22,
  22,
  22,
  22,
  22, -- All for the love of you!
  24,
  25,
  24,
  22,
  27,
  27,
  24,
  22,
  20,
  20,
  20,
  20, -- It won't be a stylish marriage,
  22,
  24,
  24,
  20,
  17,
  17,
  19,
  17,
  15,
  15,
  15,
  14, -- I can't afford a carriage,
  15,
  20,
  20,
  24,
  22,
  22,
  15,
  20,
  20,
  24,
  22, -- But you'll look sweet on the seat
  24,
  25,
  27,
  24,
  20,
  22,
  22,
  15,
  20,
  20,
  20,
  20,
  20,
  20 -- Of a bicycle built for two!
}
