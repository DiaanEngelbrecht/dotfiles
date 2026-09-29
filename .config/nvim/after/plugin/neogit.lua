local neogit = require('neogit')

neogit.setup {
  use_magit_keybindings = true,
  disable_hint = true,
  disable_context_highlighting = true,
  disable_commit_confirmation = true,
  auto_refresh = false,
  use_telescope = true,
  kind = "auto",
  integrations = {
    telescope  = true,
    diffview = true
  },
  mappings = {
    finder = {
        ["<C-j>"] = "Next",
        ["<C-k>"] = "Previous",
        ["<C-g>"] = "Close",
    }
  }
}
