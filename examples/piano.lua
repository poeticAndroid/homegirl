square = createsample()

function _init()
  len = 32
  while len > 0 do
    len = len - 1
    val = 127
    if len < 16 then
      val = -127
    end
    editsample(square, len, val)
  end
  editsampleloop(square, 0, 32)
  editsamplerate(square, 44000)
  playsample(0, square)
  playsample(3, square)
  setvolume(0, 2)
  setvolume(3, 2)
end

function _step(t)
  setsamplerate(0, t)
  setsamplerate(3, t + 100)
end
