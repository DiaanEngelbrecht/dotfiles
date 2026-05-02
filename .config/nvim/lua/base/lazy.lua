local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "       -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`

require("lazy").setup({
    -- TODO: consider using blink in the future
    -- {
    --   'saghen/blink.cmp',
    --   -- optional: provides snippets for the snippet source
    --   dependencies = { 'rafamadriz/friendly-snippets' },
    -- },
  'neovim/nvim-lspconfig',
  { "navarasu/onedark.nvim",     lazy = false,  priority = 1000 },
  { "mason-org/mason.nvim" },
  { 'akinsho/git-conflict.nvim', version = "*", config = true },
  "ojroques/nvim-bufdel",
  "xiyaowong/transparent.nvim",
  "christoomey/vim-tmux-navigator",
  "lukas-reineke/indent-blankline.nvim",
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  "nvim-telescope/telescope-file-browser.nvim",
  "nvim-telescope/telescope-project.nvim",
  { 'akinsho/toggleterm.nvim', version = "*", opts = { --[[ things you want to change go here]] } },
  "numToStr/Comment.nvim",
  "nvim-treesitter/nvim-treesitter",
  {
    "mfussenegger/nvim-lint",
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('lint').linters_by_ft = {
        typescript = { 'eslint' },
        elixir = { 'credo' },
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end
  },
  'mhartington/formatter.nvim',
  {
    'glepnir/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        -- config
        theme = 'hyper',
        config = require('base.dashboard').config,
      }
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  "rcarriga/nvim-notify",
  "stevearc/dressing.nvim",
  { "kevinhwang91/nvim-bqf",   ft = 'qf' },
  {
    "NeogitOrg/neogit",
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      "nvim-telescope/telescope.nvim"
    },
    config = true
  },
  { "echasnovski/mini.nvim", branch = 'stable' },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { 'kyazdani42/nvim-web-devicons', opt = true }
  },
  "emmanueltouzery/agitator.nvim",
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    dir = "/Users/diaan/repos/buckety",
    name = "buckety",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
  },
  {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  opts = {
    provider = "claude-code",
    auto_suggestions_provider = "claude-code",
    -- providers = {
    --   claude = {
    --     endpoint = "https://api.anthropic.com",
    --     model = "claude-3-7-sonnet-20250219",
    --     extra_request_body = {
    --       temperature = 0,
    --       max_tokens = 4096,
    --     }
    --   },
    -- },
    behaviour = {
      auto_suggestions = false, -- Experimental stage
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
      enable_token_counting = true, -- Whether to enable token counting. Default to true.
    },
    acp_providers = {
      ["claude-code"] = {
        command = "npx",
        args = { "@zed-industries/claude-code-acp" },
        env = {
          NODE_NO_WARNINGS = "1",
          HOME = vim.fn.getenv('HOME')
          -- ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
        },
      }
    }
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
})
