
dofile('serious.lua')

file = assert(io.open('data.xml', 'r'))
str = assert(file:read('*all'))
file:close()

t = parseXML(str)

export(io.stdout, t)
