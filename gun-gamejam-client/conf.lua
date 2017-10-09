local conf = {}

conf.width = 400
conf.height = 400

function love.conf(t)
  t.title = 'gun-gamejam'
  t.identity = 'gun-gamejam'
  t.console = true -- attach a console to the windows version
  t.window.width = conf.width
  t.window.height = conf.height
  t.window.msaa = 8
end

return conf
