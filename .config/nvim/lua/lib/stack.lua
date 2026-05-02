-- Bubble Up Stack Table
-- Uses a table as stack, use <table>:push(value) and <table>:pop()

-- GLOBAL
BubbleStack = {}

-- Create a Table with stack functions
function BubbleStack:Create()

  -- stack table
  local t = {}
  -- entry table
  t._et = {}

  -- push a value on to the stack or bubble it up
  function t:push_bubble(...)
    if ... then
      local targs = {...}
      -- add values
      for _,v in ipairs(targs) do
        for i, p in ipairs(self._et) do
          if p == v then
            table.remove(self._et, i)
          end
        end
        table.insert(self._et, v)
      end
    end
  end


  -- remove
  function t:remove(...)
    if ... then
      local targs = {...}
      -- add values
      for _,v in ipairs(targs) do
        for i, p in ipairs(self._et) do
          if p == v then
            table.remove(self._et, i)
          end
        end
      end
    end
  end

  -- get entries
  function t:getn()
    return #self._et
  end


  -- get index
  function t:get_index(bufnr)
    for i, p in ipairs(self._et) do
      if p == bufnr then
        return i
      end
    end
  end

  -- list values
  function t:list()
    for i,v in pairs(self._et) do
      print(i, v)
    end
  end
  
  -- clean up phantom buffers
  function t:cleanup_phantoms()
    local valid_buffers = {}
    for _, buf in ipairs(self._et) do
      if vim.fn.bufexists(buf) == 1 and vim.fn.buflisted(buf) == 1 then
        table.insert(valid_buffers, buf)
      end
    end
    self._et = valid_buffers
  end
  
  -- get visible buffers from stack (excluding current)
  function t:get_visible_buffers()
    self:cleanup_phantoms()
    local current_buf = vim.api.nvim_get_current_buf()
    local visible = {}
    for i = #self._et, 1, -1 do
      if self._et[i] ~= current_buf then
        table.insert(visible, self._et[i])
      end
    end
    return visible
  end
  
  return t
end
