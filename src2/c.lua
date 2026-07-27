local M = {}
function M.parse(s)
  local out = {}
  for k, v in string.gmatch(s, "(%w+)=(%w+)") do out[k] = v end
  return out
end
return M
