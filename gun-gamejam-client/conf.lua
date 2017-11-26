local conf = {}

conf.width = 640
conf.height = 640

function love.conf(t)
  t.title = 'gun-gamejam'
  t.identity = 'gun-gamejam'
  t.console = true -- attach a console to the windows version
  t.window.width = conf.width
  t.window.height = conf.height
  t.window.msaa = 8
end

return conf
