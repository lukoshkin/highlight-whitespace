vim.schedule_wrap(function()
  if not require 'highlight-whitespace'._set_up then
    require 'highlight-whitespace'.setup()
  end
end)
