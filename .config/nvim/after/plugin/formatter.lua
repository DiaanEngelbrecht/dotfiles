require("formatter").setup {
  -- Enable or disable logging
  logging = true,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    -- Formatter configurations for filetype "lua" go here
    -- and will be executed in order
    typescript = {
      require("formatter.filetypes.typescript").prettier,
    },
    json = {
      require("formatter.filetypes.json").prettier,
    },
    elixir = {
      require("formatter.filetypes.elixir").mixformat,
    },
    python = {
      require("formatter.filetypes.python").autopep8,
    },
    svelte = {
      require("formatter.filetypes.svelte").prettier,
    },
    toml = {
      require("formatter.filetypes.toml").taplo,
    },
    sql = {
      require("formatter.filetypes.sql").pgformat,
    },

    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ["*"] = {
      require("formatter.filetypes.any").remove_trailing_whitespace,
    }
  }
}
