square = audio.new()

function _init()
  len = 32
  while len > 0 do
    len = len - 1
    val = 127
    if len < 16 then
      val = -127
    end
    audio.edit(square, len, val)
  end
  audio.editloop(square, 0, 32)
  audio.editrate(square, 44000)
  audio.play(0, square)
  audio.play(3, square)
  audio.setvolume(0, 2)
  audio.setvolume(3, 2)
end

function _step(t)
  audio.setrate(0, t)
  audio.setrate(3, t + 100)
end
