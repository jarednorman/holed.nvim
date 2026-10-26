-- Sanity check for the colorscheme. Run with `make check`:
--   nvim --headless --clean --cmd 'set rtp+=.' -l check.lua
local problems = {}
local function problem(fmt, ...)
  problems[#problems + 1] = fmt:format(...)
end

-- 1. The group table builds without errors, and every colour is a hex string.
local holed = require("holed")
local groups = require("holed.highlights").build(holed.config)
for name, spec in pairs(groups) do
  for _, key in ipairs({ "fg", "bg", "sp" }) do
    local v = spec[key]
    if v ~= nil and not (type(v) == "string" and v:match("^#%x%x%x%x%x%x$")) then
      problem("%s.%s is %s, expected #rrggbb", name, key, vim.inspect(v))
    end
  end
end

-- 2. Every link target is defined by holed or by Neovim's defaults.
local ok, err = pcall(vim.cmd.colorscheme, "holed")
if not ok then
  problem("colorscheme holed failed: %s", err)
end
local defined = vim.api.nvim_get_hl(0, {})
for name, spec in pairs(groups) do
  if spec.link and not defined[spec.link] then
    problem("%s links to undefined group %s", name, spec.link)
  end
end

-- 3. Neovim's terminal colours match the generated Ghostty theme.
local ghostty = {}
for line in io.lines("extras/ghostty/holed") do
  local n, hex = line:match("^palette = (%d+)=(#%x+)$")
  if n then
    ghostty[tonumber(n)] = hex
  end
end
for i = 0, 15 do
  local nvim_hex = vim.g["terminal_color_" .. i]
  if ghostty[i] ~= nvim_hex then
    problem("terminal_color_%d is %s but Ghostty has %s", i, tostring(nvim_hex), tostring(ghostty[i]))
  end
end

if #problems > 0 then
  io.stderr:write(table.concat(problems, "\n") .. "\n")
  os.exit(1)
end
print(("holed ok: %d groups"):format(vim.tbl_count(groups)))
