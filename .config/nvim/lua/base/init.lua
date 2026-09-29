require("base.lazy")
require("base.keybindings")
require("base.theme")
require("base.set")
require("base.lsp")

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "help",
    "dashboard",
    "NvimTree",
    "mason",
    "notify",
  },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})
