local conf = {}

conf.width = 100
conf.height = 100

function love.conf(t)
  t.title = 'gun-gamejam'
  t.identity = 'gun-gamejam'
  t.window.width = conf.width
  t.window.height = conf.height
  t.window.msaa = 8
end

return conf
