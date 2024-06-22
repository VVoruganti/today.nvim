if vim.fn.has('nvim-0.7') == 0 then
  vim.api.nvim_err_writeln('Today requires at least nvim-0.7')
  return
end

-- make sure this plugin can be loaded more than once
if vim.g.loaded_today == 1 then
  return
end
vim.g.loaded_today = 1

vim.api.nvim_create_user_command('Today', function(opts)
  require('today').today(opts)
end, { nargs = '?', count = true })
