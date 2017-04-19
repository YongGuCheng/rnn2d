require 'rnn2d'
require 'image'
require 'warp_ctc'

-- Prepare input images!
local img1 = image.load('../../assets/a.png')  -- 3 x H x W
local img2 = image.load('../../assets/ab.png') -- 3 x H x W

local K = math.max(img1:size(1), img2:size(1))
local H = math.max(img1:size(2), img2:size(2))
local W = math.max(img1:size(3), img2:size(3))
local N = 2
local D = 5

local img = torch.zeros(N, K, H, W)
img:sub(1, 1,
	1, img1:size(1),
	1, img1:size(2),
	1, img1:size(3)):copy(1.0 - img1)
img:sub(2, 2,
	1, img2:size(1),
	1, img2:size(2),
	1, img2:size(3)):copy(1.0 - img2)
img = img:permute(3, 4, 1, 2):contiguous()

local model = nn.Sequential()
model:add(rnn2d.LSTM(K, D, false))  -- Regular LSTM-2D Cells
model:add(rnn2d.Collapse('sum', 4, D))
model:add(nn.Sum(1))
model:add(nn.View(-1, D))

model:get(1).weight = torch.DoubleTensor({
 0.0,  0.0,  0.0,  0.0,  0.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
-0.1,  0.1, -0.0,  0.1,  0.1, -0.1, -0.1,  0.1,  0.2,  0.2, -0.1,  0.0,  0.1,  0.1, -0.1,  0.0,  0.0, -0.2,  0.1,  0.2, -0.1,  0.1, -0.2, -0.1,  0.2,
 0.1, -0.0,  0.1, -0.1,  0.0,  0.2, -0.0,  0.1, -0.2,  0.1,  0.1, -0.1,  0.2, -0.0,  0.2, -0.2, -0.2, -0.2,  0.1,  0.0,  0.0, -0.2,  0.0, -0.1,  0.0,
-0.2,  0.1,  0.0, -0.2,  0.1,  0.2,  0.1,  0.2,  0.2,  0.1, -0.1,  0.1, -0.0, -0.1, -0.1, -0.2, -0.0,  0.2, -0.2, -0.2,  0.1,  0.0, -0.0, -0.2, -0.1,
0.2, -0.0,  0.0, -0.2, -0.1, -0.0,  0.1,  0.2,  0.1,  0.1, -0.2,  0.1,  0.2,  0.1, -0.0, -0.2,  0.0,  0.0,  0.2, -0.0,  0.0,  0.0,  0.2, -0.2,  0.1,
 0.1,  0.1,  0.1,  0.0,  0.2, -0.2, -0.2,  0.0, -0.2,  0.2, -0.1, -0.1, -0.0,  0.2,  0.2, -0.1, -0.1, -0.2,  0.2,  0.1,  0.1,  0.2,  0.1,  0.0, -0.1,
-0.2, -0.1,  0.1, -0.2, -0.2, -0.1,  0.0,  0.2, -0.1, -0.2, -0.2,  0.2, -0.2, -0.1,  0.0, -0.2,  0.2,  0.2,  0.0, -0.2, -0.1,  0.1, -0.2,  0.0, -0.1,
 0.2,  0.1, -0.1, -0.2,  0.1,  0.1,  0.1,  0.2,  0.1,  0.0, -0.1,  0.1,  0.2,  0.2,  0.2,  0.2,  0.0, -0.0,  0.2,  0.2,  0.0, -0.1, -0.1,  0.2, -0.1,
 0.1, -0.1,  0.1,  0.1,  0.1,  0.1, -0.0,  0.2,  0.1, -0.0, -0.2, -0.1,  0.1, -0.0, -0.1,  0.1, -0.2, -0.2,  0.1, -0.2, -0.1,  0.0, -0.2,  0.1,  0.2,
 0.2,  0.2,  0.1,  0.2,  0.1,  0.1, -0.2, -0.0, -0.1, -0.1, -0.2,  0.1,  0.0,  0.1,  0.1, -0.1, -0.0, -0.0, -0.0,  0.2, -0.1, -0.2,  0.2,  0.2, -0.1,
 0.1, -0.1, -0.1, -0.1, -0.0, -0.2,  0.1,  0.1,  0.2, -0.1, -0.1, -0.1,  0.2,  0.2, -0.0, -0.2, -0.2, -0.2,  0.0, -0.2, -0.1, -0.2,  0.1, -0.2,  0.2,
-0.1,  0.1,  0.0, -0.2,  0.0,  0.1, -0.2,  0.1,  0.1,  0.0,  0.1,  0.1, -0.1,  0.1,  0.2,  0.1,  0.1, -0.0,  0.2,  0.1, -0.1,  0.0, -0.1, -0.2,  0.0,
 0.2,  0.2,  0.1, -0.2, -0.0, -0.2, -0.2,  0.0, -0.2,  0.0,  0.0,  0.2,  0.1,  0.2, -0.1, -0.1,  0.1,  0.2,  0.2,  0.1, -0.1,  0.1,  0.2,  0.1, -0.2,
-0.1,  0.2, -0.0,  0.0,  0.0, -0.1, -0.2,  0.0,  0.2, -0.1,  0.1, -0.2, -0.2, -0.2, -0.2, -0.1,  0.0,  0.1,  0.2,  0.1,  0.2,  0.0,  0.1,  0.0,  0.2,

 0.0,  0.0,  0.0,  0.0,  0.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
-0.2,  0.1, -0.2, -0.2, -0.2, -0.2,  0.0, -0.0,  0.2, -0.2, -0.1,  0.2, -0.0,  0.2,  0.0,  0.2,  0.2,  0.1, -0.2,  0.2,  0.0, -0.1,  0.2, -0.1, -0.2,
 0.1,  0.2,  0.0, -0.0, -0.2,  0.1,  0.2,  0.2,  0.2, -0.2,  0.1, -0.0, -0.1, -0.2,  0.2,  0.1, -0.2,  0.2,  0.1, -0.1,  0.2,  0.0, -0.2, -0.0, -0.0,
-0.1,  0.2,  0.1,  0.0, -0.0, -0.0, -0.1,  0.1,  0.1, -0.1,  0.0, -0.2,  0.1,  0.2,  0.0,  0.2, -0.2, -0.2, -0.0,  0.2,  0.2, -0.0,  0.2, -0.1, -0.1,
 0.1,  0.1, -0.2, -0.1,  0.0,  0.2, -0.1, -0.2,  0.0,  0.1, -0.1,  0.2,  0.2,  0.1, -0.1,  0.2,  0.2,  0.1,  0.2, -0.1, -0.0,  0.1,  0.2,  0.1,  0.2,
 0.1, -0.2,  0.2, -0.1,  0.2, -0.0, -0.2,  0.2, -0.2,  0.1, -0.2, -0.2,  0.1,  0.2,  0.1,  0.1, -0.0, -0.2, -0.1,  0.1, -0.2, -0.0, -0.2,  0.1,  0.0,
 0.0,  0.2,  0.2, -0.1,  0.1,  0.1, -0.1,  0.2,  0.0,  0.0, -0.1, -0.1, -0.1,  0.2, -0.1,  0.1,  0.0, -0.2,  0.0, -0.1, -0.2,  0.2, -0.2,  0.2, -0.1,
-0.0, -0.2, -0.2, -0.0,  0.1, -0.2,  0.2, -0.2,  0.1, -0.0,  0.1, -0.1, -0.2, -0.0,  0.1, -0.2,  0.1, -0.1,  0.0, -0.1, -0.1,  0.2,  0.2, -0.2,  0.1,
 0.2,  0.1,  0.0, -0.2, -0.2,  0.2, -0.2,  0.0,  0.2, -0.2,  0.1, -0.0, -0.2, -0.2, -0.2, -0.1, -0.2, -0.0, -0.2,  0.2,  0.2,  0.1, -0.1,  0.0,  0.2,
 0.2, -0.2, -0.1,  0.1,  0.1,  0.1,  0.2,  0.1, -0.1, -0.2,  0.1, -0.1, -0.2,  0.1,  0.2, -0.2, -0.2, -0.0, -0.1, -0.2, -0.2, -0.0, -0.2,  0.2,  0.2,
-0.2, -0.1, -0.0,  0.2,  0.1, -0.2,  0.2,  0.2, -0.1, -0.2, -0.2, -0.2,  0.2, -0.2, -0.1,  0.1,  0.1, -0.1, -0.1, -0.2, -0.0,  0.1,  0.1, -0.1,  0.2,
-0.2,  0.2, -0.1, -0.2, -0.1,  0.2,  0.2, -0.1, -0.1,  0.0, -0.1, -0.2,  0.1,  0.0, -0.2,  0.1,  0.2,  0.1, -0.1, -0.1, -0.1, -0.0,  0.0,  0.1, -0.2,
 0.2,  0.1, -0.2,  0.2, -0.2,  0.1, -0.2, -0.1, -0.1, -0.2, -0.0,  0.1,  0.1,  0.0,  0.0, -0.2,  0.1,  0.2, -0.1,  0.0,  0.2,  0.1, -0.1, -0.1,  0.2,
-0.1, -0.1, -0.2, -0.0, -0.1,  0.0, -0.2, -0.1, -0.0,  0.1,  0.1, -0.1, -0.2, -0.1, -0.0, -0.2, -0.0,  0.2,  0.2, -0.1,  0.2, -0.2, -0.1,  0.1, -0.2,

 0.0,  0.0,  0.0,  0.0,  0.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
-0.0, -0.1,  0.2,  0.1, -0.1, -0.2,  0.1, -0.0,  0.2,  0.0,  0.2,  0.2, -0.0, -0.2, -0.2, -0.1,  0.0,  0.1,  0.0, -0.2,  0.2,  0.1, -0.1,  0.2, -0.2,
-0.2,  0.0,  0.2, -0.2,  0.0, -0.2, -0.2, -0.2,  0.2, -0.0, -0.2,  0.1,  0.0, -0.0,  0.1, -0.2, -0.1, -0.1, -0.1, -0.2, -0.0,  0.1, -0.2, -0.1, -0.1,
 0.1, -0.1, -0.0,  0.1, -0.2, -0.0,  0.1,  0.2, -0.1,  0.2,  0.1,  0.1,  0.1,  0.2, -0.1, -0.2, -0.1, -0.2,  0.1,  0.2,  0.2, -0.0,  0.0, -0.1, -0.2,
 0.1, -0.2,  0.1,  0.2, -0.0,  0.2, -0.0, -0.1,  0.1, -0.0,  0.1, -0.0,  0.0,  0.2,  0.0,  0.2, -0.2, -0.2,  0.1,  0.0,  0.1,  0.2,  0.2,  0.1, -0.1,
 0.2, -0.1,  0.1,  0.1, -0.0, -0.1, -0.0,  0.2,  0.1, -0.2,  0.0, -0.2,  0.2,  0.2,  0.1, -0.1, -0.0,  0.2, -0.1,  0.1, -0.0, -0.2, -0.2,  0.2,  0.2,
 0.2, -0.1, -0.1,  0.1,  0.0,  0.2,  0.1, -0.2,  0.2,  0.2, -0.2,  0.2, -0.2,  0.2,  0.2,  0.2,  0.1, -0.1,  0.0, -0.1,  0.2, -0.2, -0.1,  0.1, -0.1,
 0.1, -0.1,  0.2,  0.1, -0.0, -0.1,  0.2, -0.2, -0.1, -0.1,  0.0,  0.1,  0.2, -0.2,  0.1, -0.2, -0.1,  0.2, -0.2, -0.1,  0.1,  0.2, -0.2,  0.0, -0.0,
 0.2, -0.2, -0.2, -0.2, -0.1, -0.1, -0.2, -0.2, -0.2,  0.1, -0.1,  0.2, -0.1,  0.2, -0.1, -0.1,  0.0,  0.0, -0.0, -0.1, -0.1, -0.0, -0.0, -0.1,  0.1,
 0.2,  0.0, -0.0, -0.1,  0.2, -0.2,  0.0,  0.1,  0.1, -0.0, -0.2,  0.1,  0.0,  0.1,  0.0, -0.0,  0.2,  0.2,  0.0,  0.1, -0.2,  0.2,  0.2, -0.1,  0.2,
 0.1, -0.0,  0.0,  0.1, -0.1, -0.0,  0.2,  0.1, -0.1, -0.2, -0.0,  0.2,  0.1, -0.0,  0.0, -0.2,  0.2,  0.1,  0.1,  0.2, -0.1,  0.1,  0.2,  0.1,  0.0,
 0.2, -0.0, -0.1,  0.2,  0.1, -0.0, -0.2,  0.2,  0.1, -0.2, -0.0,  0.0, -0.1, -0.0, -0.0,  0.0,  0.2,  0.2,  0.1,  0.0,  0.1,  0.1,  0.0,  0.1,  0.2,
 0.1,  0.1, -0.2, -0.0, -0.1, -0.2,  0.1, -0.2, -0.2,  0.1,  0.0, -0.0, -0.1, -0.2, -0.1, -0.1, -0.2,  0.1, -0.1,  0.2,  0.1,  0.2,  0.2,  0.0, -0.1,
 0.2, -0.2, -0.1, -0.1, -0.0,  0.2,  0.0, -0.1,  0.0,  0.2, -0.2,  0.2, -0.2,  0.2,  0.1, -0.0, -0.1,  0.1,  0.2,  0.0, -0.0, -0.2, -0.2,  0.1, -0.0,

  0.0,  0.0,  0.0,  0.0,  0.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
-0.1, -0.1,  0.1,  0.2,  0.0,  0.2, -0.2,  0.2,  0.1, -0.0,  0.2, -0.1,  0.0, -0.2, -0.1, -0.1, -0.2, -0.2, -0.1, -0.1,  0.2,  0.2, -0.2,  0.0, -0.0,
-0.0,  0.2,  0.0,  0.1,  0.2,  0.1, -0.0, -0.2, -0.0, -0.1, -0.1, -0.2, -0.1,  0.2, -0.0, -0.2,  0.1, -0.2, -0.2, -0.2, -0.0,  0.1, -0.2,  0.0,  0.1,
 0.2,  0.0,  0.2,  0.0, -0.2, -0.0,  0.0, -0.2,  0.1, -0.2, -0.0,  0.2, -0.2, -0.2, -0.2, -0.2,  0.2,  0.1,  0.1, -0.2,  0.2,  0.2,  0.1,  0.2, -0.0,
-0.0,  0.1, -0.1,  0.1, -0.0,  0.1, -0.1,  0.1, -0.0, -0.0,  0.2, -0.2, -0.2, -0.1,  0.0,  0.2, -0.1, -0.2,  0.2,  0.2, -0.2, -0.2,  0.2, -0.2,  0.0,
-0.0, -0.1, -0.2,  0.2,  0.2,  0.1,  0.1, -0.1,  0.2,  0.1, -0.0, -0.1, -0.2,  0.2, -0.1, -0.1, -0.1,  0.1,  0.2,  0.0,  0.1, -0.1, -0.2,  0.1, -0.1,
-0.2,  0.0,  0.0, -0.1, -0.2, -0.0,  0.0, -0.2,  0.2, -0.1, -0.2, -0.1, -0.2,  0.2,  0.1, -0.1, -0.2, -0.0,  0.1,  0.1, -0.1,  0.1,  0.2,  0.0, -0.0,
-0.2,  0.0,  0.1, -0.2,  0.1, -0.2, -0.0,  0.2, -0.0, -0.2, -0.2, -0.2, -0.0,  0.1, -0.2,  0.2,  0.1, -0.2, -0.1, -0.1,  0.0, -0.0, -0.0, -0.2, -0.1,
-0.2, -0.0,  0.2,  0.1, -0.1,  0.1, -0.1, -0.0, -0.2,  0.0, -0.1, -0.1, -0.2,  0.2, -0.0,  0.1,  0.1, -0.1, -0.1, -0.1, -0.0,  0.2,  0.2, -0.0, -0.2,
-0.2, -0.1, -0.1,  0.2,  0.2, -0.2,  0.0,  0.1, -0.0,  0.0, -0.1,  0.1, -0.2,  0.2,  0.1, -0.1,  0.1,  0.2, -0.0,  0.0, -0.2, -0.0,  0.2, -0.0, -0.0,
-0.1, -0.2,  0.1,  0.0, -0.2,  0.1, -0.2, -0.1, -0.0,  0.1,  0.1,  0.1, -0.1, -0.0,  0.1,  0.0,  0.1, -0.1,  0.0, -0.1, -0.0,  0.1, -0.2, -0.1,  0.1,
 0.0,  0.2,  0.2,  0.2,  0.2,  0.0, -0.2,  0.1,  0.0,  0.1, -0.0, -0.2,  0.2,  0.2,  0.1, -0.0, -0.1, -0.1,  0.1, -0.1,  0.1, -0.2, -0.0,  0.1,  0.1,
-0.0,  0.1, -0.1, -0.1,  0.1,  0.1,  0.1, -0.2, -0.1, -0.1,  0.0, -0.2, -0.1,  0.1,  0.1,  0.1, -0.1,  0.1, -0.1, -0.1,  0.2,  0.1, -0.1,  0.0,  0.1,
-0.2, -0.2,  0.2,  0.1,  0.2, -0.2,  0.2, -0.2,  0.2, -0.1,  0.1, -0.0, -0.0, -0.1,  0.0, -0.2, -0.2, -0.1,  0.1, -0.0,  0.2, -0.2,  0.1,  0.2, -0.2,
					})

-- Choose the appropiate backend
-- model = model:cuda()
-- model = model:type('torch.CudaDoubleTensor')
-- model = model:float()
model = model:double()
model:training()
img = img:type(model:type())

param, gradParam = model:getParameters()
for i=1,20 do
  y = model:forward(img)
  local gy = y:clone():zero():float()
  losses = cpu_ctc(y:float(), gy, {{1}, {1, 2}}, {W, W})
  gy = gy:type(model:type())
  loss = (losses[1] + losses[2])

  model:zeroGradParameters()
  model:backward(img, gy)
  param:add(-0.0001, gradParam)
  print(string.format('ITER = %02d %9.5f %9.5f %9.5f %9.5f %9.5f %9.5f',
		      i - 1, y:sum(), y:mean(), y:std(), y:min(), y:max(),
		      loss))
end
