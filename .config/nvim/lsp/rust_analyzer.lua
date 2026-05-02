---@type vim.lsp.Config
return {
  -- Explicitly use the rustup-managed rust-analyzer instead of Mason's
  cmd = { vim.fn.expand("~/.cargo/bin/rust-analyzer") },
  capabilities = {
    experimental = { serverStatusNotification = true },
  },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "Cargo.lock", "build.rs" },
  -- See more: https://rust-analyzer.github.io/book/configuration.html
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        features = "all",
      },
      check = {
        command = "clippy",
        features = "all",
        allTargets = true,
      },
      diagnostics = {
        styleLints = { enable = true }
      },
      procMacro = {
        enable = true,
        attributes = {
          enable = true,
        },
        -- Make sure no macros are ignored. Map of crate -> [macro names];
        -- vim.empty_dict() forces JSON object encoding instead of an array.
        ignored = vim.empty_dict(),
      },
      cargo = {
        features = "all",
        buildScripts = {
          enable = true,
        },
      },
    },
  },
}