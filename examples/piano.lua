square = audio.createsample()

function _init()
  len = 32
  while len > 0 do
    len = len - 1
    val = 127
    if len < 16 then
      val = -127
    end
    audio.editsample(square, len, val)
  end
  audio.editsampleloop(square, 0, 32)
  audio.editsamplerate(square, 44000)
  audio.playsample(0, square)
  audio.playsample(3, square)
  audio.setvolume(0, 2)
  audio.setvolume(3, 2)
end

function _step(t)
  audio.setsamplerate(0, t)
  audio.setsamplerate(3, t + 100)
end
