local core = require'highlight-whitespace.core'
local api = vim.api
local M = {}


local aug_hws = api.nvim_create_augroup('HighlightWS', {})
api.nvim_create_autocmd(
  { 'BufWinEnter', 'WinEnter', 'TextChanged', 'CompleteDone' }, {
    callback = core.match_uws,
    group = aug_hws,
})

api.nvim_create_autocmd(
  'WinLeave', {
    callback = core.clear_uws_match,
    group = aug_hws,
})

api.nvim_create_autocmd(
  { 'InsertEnter', 'CursorMovedI' }, {
    callback = core.no_match_cl,
    group = aug_hws,
})

api.nvim_create_autocmd(
  'InsertLeave', {
    callback = core.clear_no_match_cl,
    group = aug_hws,
})

api.nvim_create_autocmd(
  'QuitPre', {
    callback = core.prune_dicts,
    group = aug_hws,
})


local default_palette = {
  markdown = {
    tws = 'RosyBrown',
    ['\\(\\S\\)\\@<=\\s\\(\\.\\|,\\)\\@='] = 'CadetBlue3',
    ['\\(\\S\\)\\@<= \\{2,\\}\\(\\S\\)\\@='] = 'SkyBlue1',
    ['\\t\\+'] = 'plum4',
  },
  other = {
    tws = 'PaleVioletRed',
    ['\\(\\S\\)\\@<=\\s\\(,\\)\\@='] = 'coral1',
    ['\\(\\S\\)\\@<= \\{2,\\}\\(\\S\\)\\@='] = 'LightGoldenrod3',
    ['\\t\\+'] = 'plum4',
  }
}


local function palette (user_palette, tws_pat)
  if user_palette == nil then
    user_palette = default_palette
  end

  local patterns = {}
  for ft, pat_dict in pairs(user_palette) do
    pat_dict[tws_pat] = pat_dict['tws'] or default_palette[ft]['tws']
    pat_dict['tws'] = nil

    patterns[ft] = pat_dict
  end

  return patterns
end


local function check_deprecated (cfg)
  if cfg.patterns ~= nil or cfg.palette ~= nil or cfg.default_color ~= nil then
    local msg = ' HighlightWhitespace: Your configuration setup is deprecated!'
    msg = msg .. '\n Please, follow the instructions at https://github.com/'
    msg = msg .. 'lukoshkin/highlight-whitespace#customization'
    vim.notify(msg, vim.log.levels.WARN)
  end
end


function M.setup(cfg)
  cfg = cfg or {}
  check_deprecated(cfg)

  core.tws = cfg.tws or '\\s\\+$'
  core.palette = palette(cfg.user_palette, core.tws)
  core.clear_on_winleave = cfg.clear_on_winleave or false
  -- core.blacklist = cfg.filetype_blacklist or { 'help' }
  M._set_up = true
end


return M
