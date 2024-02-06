local M = {}
local api = vim.api

M.default = {
  tws = '\\s\\+$',
  clear_on_winleave = false,
  -- filetype_blacklist = { 'help' },
  palette = {
    markdown = {
      tws = 'RosyBrown',
      ['\\S\\@<=\\s\\(\\.\\|,\\)\\@='] = 'CadetBlue3',
      ['\\S\\@<= \\{2,\\}\\S\\@='] = 'SkyBlue1',
      ['\\t\\+'] = 'plum4',
    },
    other = {
      tws = 'PaleVioletRed',
      ['\\S\\@<=\\s,\\@='] = 'coral1',
      ['\\S\\@<=\\(#\\|--\\)\\@<! \\{2,3\\}\\S\\@=\\(#\\|--\\)\\@!'] = 'LightGoldenrod3',
      ['\\(#\\|--\\)\\@<= \\{2,\\}\\S\\@='] = '#3B3B3B',
      ['\\S\\@<= \\{3,\\}\\(#\\|--\\)\\@='] = '#3B3B3B',
      ['\\t\\+'] = 'plum4',
    }
  }
}


local function is_valid_color(color)
  local is_valid = api.nvim_get_color_by_name(color) ~= -1
  if is_valid then
    return true
  end

  local err_msg = ' Invalid color: ' .. color
  vim.notify(err_msg, vim.log.levels.ERROR, { title = 'highlight-whitespace' })
  return false
end

function M.check_colors(cfg)
  local colors = vim.tbl_values(vim.tbl_map(vim.tbl_values, cfg.palette))
  local booleans = vim.tbl_map(is_valid_color, vim.tbl_flatten(colors))

  if vim.tbl_contains(booleans, false) then
    cfg.palette = M.default.palette
    vim.notify(' Default palette is loaded instead',
      vim.log.levels.WARN, { title = 'highlight-whitespace', })
  end
end

function M.check_config_conforms(cfg)
  local allowed_keys = vim.tbl_keys(M.default)
  local conforms = not vim.tbl_contains(
    vim.tbl_map(function(key)
      return vim.tbl_contains(allowed_keys, key)
    end, vim.tbl_keys(cfg)
    ),
    false
  )
  if not conforms then
    vim.notify(' Something strange about your config!',
      vim.log.levels.WARN, { title = 'highlight-whitespace' })
  end
end

function M.check_deprecated(cfg)
  if cfg.user_palette ~= nil then
    vim.notify(' `user_palette` key is deprecated! Use `palette` instead.',
      vim.log.levels.WARN, { title = 'highlight-whitespace' })
  end
  if cfg.patterns ~= nil or cfg.default_color ~= nil then
    local msg = ' Your configuration setup is deprecated!'
    msg = msg .. ' Please, follow the instructions at\n https://github.com/'
    msg = msg .. 'lukoshkin/highlight-whitespace#customization'
    vim.notify(msg, vim.log.levels.WARN, { title = 'highlight-whitespace' })
  end
end

return M
