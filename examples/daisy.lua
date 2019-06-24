f0 = 440
fa = math.pow(2, 1 / 12)

function tone2freq(tone)
  return f0 * math.pow(fa, tone)
end

square = audio.new()
function _init()
  len = 16
  while len > 0 do
    len = len - 1
    val = 15
    if len < 8 then
      val = -16
    end
    audio.sample(square, len, val)
  end
  audio.sampleloop(square, 0, 16)
  start, endd = audio.sampleloop()
  audio.play(1, square)
  audio.play(2, square)
end

vol = 63
pos = 0
nexttime = 0
function _step(t)
  if nexttime > t then
    audio.channelvolume(1, vol)
    audio.channelvolume(2, vol)
    if vol > 0 then
      vol = vol - 1
    end
    return
  end
  if pos == 0 then
    nexttime = t
    pos = pos + 1
  end
  audio.channelfreq(1, tone2freq(song[pos]))
  audio.channelfreq(2, tone2freq(song[pos]))
  if song[pos] ~= song[pos - 1] then
    vol = 63
  end
  pos = pos + 1
  nexttime = nexttime + 256
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
