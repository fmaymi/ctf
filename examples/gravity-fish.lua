
local array  = require 'array'
local fish   = require 'fish'
local fluids = require 'fluids'
local hdf5   = require 'lua-hdf5.LuaHDF5'

local P = array.array{100, 5}
local G = array.array{100, 4}
local Pvec = P:vector()

local dx = 1.0 / 94
local cs = 1.0

local function gravitywave()
   for n=0,#Pvec/5-1 do
      local x = (n - 50) * dx
      local D0 = 1.0
      local D1 = D0 * 1e-6
      local p0 = D0 * cs^2 / 1.4
      local p1 = D1 * cs^2
      local w0 = 4 * math.pi
      local k0 = w0 / cs
      
      Pvec[5*n + 0] = D0 + D1 * math.cos(k0 * x)
      Pvec[5*n + 1] = p0 + p1 * math.cos(k0 * x)
      Pvec[5*n + 2] = p0 + p1 * math.cos(k0 * x)
      Pvec[5*n + 3] = 0.0
      Pvec[5*n + 4] = 0.0
   end
end

local function shocktube()
   for n=0,#Pvec/5-1 do
      local x = (n - 50) * dx
      local D0 = x < 0.0 and 1.0 or 0.125
      local p0 = x < 0.0 and 1.0 or 0.1
      Pvec[5*n + 0] = D0
      Pvec[5*n + 1] = p0
      Pvec[5*n + 2] = 0.0
      Pvec[5*n + 3] = 0.0
      Pvec[5*n + 4] = 0.0
   end
end

--shocktube()
gravitywave()
fish.grav1d_init()
fish.grav1d_mapbuffer(P:buffer(), fluids.PRIMITIVE)


for n=0,100 do
   fish.grav1d_advance()
   if n % 10 == 0 then
      local fname = string.format('data/euler-%04d.h5', n)
      local outfile = hdf5.File(fname, 'w')
      outfile['prim'] = P
      outfile:close()
   end
end
fish.grav1d_finalize()
