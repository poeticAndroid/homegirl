square = audio.new()

function _init()
  len = 32
  while len > 0 do
    len = len - 1
    val = 127
    if len < 16 then
      val = -127
    end
    audio.sample(square, len, val)
  end
  audio.sampleloop(square, 0, 32)
  start, endd = audio.sampleloop()
  audio.samplefreq(square, 44000)
  audio.play(0, square)
  audio.play(3, square)
  audio.channelvolume(0, 2)
  audio.channelvolume(3, 2)
end

function _step(t)
  audio.channelfreq(0, t)
  audio.channelfreq(3, t + 100)
end
