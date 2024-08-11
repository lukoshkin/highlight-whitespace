local M = {}
local core = require "highlight-whitespace.core"

local function valid_buftype_callback(fn)
  return function(args)
    local buftype = vim.api.nvim_buf_get_option(args.buf, "buftype")
    if buftype == "nofile" or buftype == "prompt" or buftype == "terminal" then
      return
    end

    fn(args)
  end
end

local fns_to_wrap = {
  "match_uws",
  "get_matches_from_cache",
  "save_matches_to_cache_and_clear",
  "no_match_cl",
  "clear_no_match_cl",
}

for fn_name, fn in pairs(core) do
  if vim.tbl_contains(fns_to_wrap, fn_name) then
    M[fn_name] = valid_buftype_callback(fn)
  end
end

return M
