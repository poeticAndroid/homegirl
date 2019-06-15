square = createsample()

function _init()
  len = 100
  while len > 0 do
    len = len - 1
    val = 127
    if len < 50 then
      val = -127
    end
    editsample(square, len, val)
  end
  editsampleloop(square, 0, 100)
  editsamplerate(square, 44000)
  playsample(0, square)
  setvolume(0, 2)
end

function _step(t)
  setsamplerate(0, t)
end
