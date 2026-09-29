require("lib.stack")

local tree_api = require("nvim-tree.api")

local function run_code()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code = table.concat(lines, "\n")
  local filetype = vim.bo.filetype

  local interpreters = {
    python = "python",
    lua = "lua",
    sh = "bash",
    javascript = "node",
  }

  local interpreter = interpreters[filetype]
  if not interpreter then
    vim.notify("No interpreter found for filetype: " .. filetype, vim.log.levels.ERROR)
    return
  end

  local temp_file = "/tmp/scratch_code." .. filetype
  local file = io.open(temp_file, "w")
  file:write(code)
  file:close()

  local result = vim.fn.system(interpreter .. " " .. temp_file)

  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result, "\n"))
end

vim.api.nvim_create_user_command("Scratch", function()
  local scratch_name = "ScratchBuffer"

  local function get_basename(bufname)
    return bufname:match("^.+/(.+)$") or bufname -- Extract the basename, or return as-is if no path
  end

  -- Check if a buffer named ScratchBuffer already exists
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if get_basename(vim.api.nvim_buf_get_name(buf)) == scratch_name then
      -- Navigate to the existing ScratchBuffer
      vim.api.nvim_set_current_buf(buf)
      return
    end
  end
  -- Create a new buffer
  vim.cmd("enew")

  -- Set the buffer to be a scratch buffer
  vim.bo.buftype = "nofile"
  vim.bo.swapfile = false

  -- Set the buffer name
  vim.api.nvim_buf_set_name(0, scratch_name)
end, {})

vim.keymap.set("n", "<leader>rc", run_code, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>bs", "<cmd>:Scratch<cr>")

vim.keymap.set("n", "<leader>fj", vim.cmd.Ex)
vim.keymap.set("n", "<leader>fs", "<cmd>:w<cr>")

-- Shortcuts to very quickly edit
vim.keymap.set("n", "<leader>eb", "<cmd>:e ~/.zshrc<cr>")
vim.keymap.set("n", "<leader>es", "<cmd>:e ~/.ssh/config<cr>")
vim.keymap.set("n", "<leader>eh", "<cmd>:e ~/.ssh/known_hosts<cr>")

vim.keymap.set("n", "<leader>ll", "<cmd>:LspInfo<cr>")
vim.keymap.set("n", "<leader>lf", function()
    local filetype = vim.bo.filetype

    if filetype == "rust" then
        -- If it's a Rust file, call the LSP formatter (rust-analyzer)
        vim.lsp.buf.format()
    else
        -- For all other files, try formatter.nvim
        -- It will handle files based on the configuration in formatter.lua
        vim.cmd("Format")
    end
end, { desc = "Format File (LSP or Formatter.nvim)" })
vim.keymap.set("n", "<leader>ls", "<cmd>:Mason<cr>")

vim.keymap.set("n", "<leader>qq", function()
  if tree_api.tree.is_visible() then
    tree_api.tree.close()
  end
  vim.cmd(":q")
end)


vim.keymap.set("n", "<leader>ld", function()
  local linters = require("lint").get_running()
  vim.print("Active linters" .. table.concat(linters, ", "))
end)

vim.keymap.set("n", "<leader>cr", "<cmd>%s/\\r//g<cr>")
vim.keymap.set("n", "<leader>c/", "<cmd>let @/ = \"\"<cr>")

vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

vim.keymap.set("n", "<leader><C-o>", function()
  local jl = vim.fn.getjumplist()
  local currentJump = jl[2]
  for i = currentJump, 0, -1 do
    if jl[1][i]["bufnr"] ~= vim.fn.bufnr('%') then
      vim.cmd([[execute "normal! ]] .. (currentJump - i + 1) .. [[\<c-o>"]])
      break
    end
  end
end)

_G.BufStack = BubbleStack:Create()

vim.keymap.set("n", "<leader><tab>", function()
  _G.BufStack:cleanup_phantoms()
  local visible_buffers = _G.BufStack:get_visible_buffers()

  if #visible_buffers > 0 then
    -- Switch to most recent buffer (first in visible_buffers)
    vim.api.nvim_set_current_buf(visible_buffers[1])
  else
    vim.notify("No other buffers in stack", vim.log.levels.INFO)
  end
end, { desc = "Switch to Other Buffer" })

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function(args)
    local buftype = vim.bo[args.buf].buftype
    local filetype = vim.bo[args.buf].filetype
    local bufname = vim.api.nvim_buf_get_name(args.buf)

    -- Exclude special buffers and plugin buffers
    local excluded_filetypes = {
      "help", "qf", "fugitive", "git", "gitcommit", "gitrebase",
      "NvimTree", "telescope", "TelescopePrompt", "toggleterm",
      "netrw", "mason", "lazy", "lspinfo"
    }

    local excluded_buftypes = {
      "help", "quickfix", "terminal", "prompt", "nofile", "acwrite"
    }

    local excluded_patterns = {
      "^fugitive://", "^term://", "^NvimTree", "^toggleterm"
    }

    -- Check exclusions
    for _, ft in ipairs(excluded_filetypes) do
      if filetype == ft then return end
    end

    for _, bt in ipairs(excluded_buftypes) do
      if buftype == bt then return end
    end

    for _, pattern in ipairs(excluded_patterns) do
      if bufname:match(pattern) then return end
    end

    -- Only add normal, listed buffers to stack
    if vim.fn.buflisted(args.buf) == 1 and buftype == "" then
      _G.BufStack:push_bubble(args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  callback = function(args)
    if vim.fn.buflisted(args.buf) == 1 and vim.bo[args.buf].buftype == "" then
      -- vim.print("Leaving buffer: " .. vim.inspect(args.buf))
      _G.BufStack:remove(args.buf)
    end
  end,
})

-- Cleanup phantom buffers on buffer enter
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function()
    _G.BufStack:cleanup_phantoms()
  end,
})

vim.keymap.set("n", "<leader>bd", function()
  local current_buff = vim.api.nvim_get_current_buf()
  if vim.fn.buflisted(current_buff) == 1 and vim.bo[current_buff].buftype == "" then
    local len = _G.BufStack:getn()
    if len > 1 then
      vim.api.nvim_set_current_buf(_G.BufStack._et[len - 1])
    end
  end
  vim.cmd(":BufDel " .. current_buff)
end)

vim.keymap.set("n", "<leader>t", function()
    vim.cmd(":ToggleTerm")
end)

vim.keymap.set("t", "<C-t>", "<cmd>:ToggleTerm<cr>")
vim.api.nvim_set_keymap("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "fd", [[<C-\><C-n>]], { noremap = true, silent = true })

vim.keymap.set("n", "<leader>w", "<C-w>")
vim.keymap.set("n", "<leader>wd", "<C-w>c")
vim.keymap.set("n", "<leader>fc", "<cmd>:cd %:h<cr>")

local neogit = require('neogit')
local utils = require('telescope.utils')
vim.keymap.set("n", "<leader>gs", function()
  neogit.open({ cwd = utils.buffer_dir() })
end)
vim.keymap.set("n", "<leader>gb", function()
  -- require('agitator').git_blame()
  require 'agitator'.git_blame_toggle {
    sidebar_width = 35,
    formatter = function(r)
      return r.date.year ..
          "/" .. r.date.month .. "/" .. r.date.day .. ":" .. r.author:sub(0, 5) .. " - " .. r.summary;
    end }
end)
vim.keymap.set("n", "<leader>gt", function()
  require('agitator').git_time_machine({ use_current_win = true })
end)

vim.keymap.set("i", "fd", "<Esc>")