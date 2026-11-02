-- Keep terminal Neovim's modal controls; the GUI starts with familiar editing keys.
do
  if vim.g.neovide then
    local api = vim.api
    local function editable(buf)
      buf = buf or api.nvim_get_current_buf()
      return api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].modifiable
        and vim.fn.isdirectory(api.nvim_buf_get_name(buf)) == 0
    end
    local function keys(value) return api.nvim_replace_termcodes(value, true, false, true) end
    local function normal(value) vim.cmd.normal({ args = { keys(value) }, bang = true }) end
    local function is_selected()
      return vim.fn.mode():match("^[vV\22sS\19]") ~= nil
    end
    local function visual()
      if vim.fn.mode():match("^[sS\19]") then normal("<C-G>") end
    end
    local function insert_at(row, col)
      local line = api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
      api.nvim_win_set_cursor(0, { row, math.min(col, #line) })
      vim.cmd.startinsert()
    end

    vim.opt.selection = "exclusive"
    vim.opt.selectmode = { "mouse", "key" }
    vim.opt.keymodel = { "startsel", "stopsel" }
    vim.opt.mousemodel = "popup_setpos"
    vim.opt.backspace = { "indent", "eol", "start" }
    vim.opt.whichwrap:append("<,>,[,]")
    vim.opt.virtualedit:append("onemore")

    local function copy()
      if not editable() then return end
      if is_selected() then
        local cursor = api.nvim_win_get_cursor(0)
        visual()
        normal('"+y')
        insert_at(cursor[1], cursor[2])
      else
        vim.fn.setreg("+", { api.nvim_get_current_line() }, "V")
      end
    end
    local function cut()
      if not editable() then return end
      if is_selected() then
        visual()
        normal('"+d')
        local start = vim.fn.getpos("'[")
        insert_at(math.min(start[2], api.nvim_buf_line_count(0)), math.max(0, start[3] - 1))
      else
        local row = api.nvim_win_get_cursor(0)[1]
        vim.fn.setreg("+", { api.nvim_get_current_line() }, "V")
        api.nvim_buf_set_lines(0, row - 1, row, false, {})
        insert_at(math.min(row, api.nvim_buf_line_count(0)), 0)
      end
    end
    local function paste()
      if not editable() then return end
      local clipboard = vim.fn.getreginfo("+")
      local text = table.concat(clipboard.regcontents or {}, "\n")
        .. (clipboard.regtype == "V" and "\n" or "")
      if text == "" then return end
      local mode = vim.fn.mode()
      if clipboard.regtype == "V" and not is_selected() then
        local cursor = api.nvim_win_get_cursor(0)
        api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1] - 1, false, clipboard.regcontents)
        insert_at(cursor[1] + #clipboard.regcontents, cursor[2])
        return
      end
      -- nvim_paste handles Select/Visual replacement and literal multiline text.
      -- Preserve the clipboard when deleting a selection with unnamedplus enabled.
      api.nvim_paste(text, true, -1)
      vim.fn.setreg("+", clipboard)
      if not mode:match("^i") then
        local cursor = api.nvim_win_get_cursor(0)
        local line = api.nvim_get_current_line()
        local advance = text:sub(-1) == "\n" and 0 or #vim.fn.strcharpart(line:sub(cursor[2] + 1), 0, 1)
        insert_at(cursor[1], cursor[2] + advance)
      end
    end
    local function select_all()
      if not editable() then return end
      api.nvim_feedkeys(keys("<Esc>gg0vG$<C-G>"), "ni", false)
    end
    local redo_positions = {}
    local function undo()
      if not editable() then return end
      local buf = api.nvim_get_current_buf()
      redo_positions[buf] = redo_positions[buf] or {}
      redo_positions[buf][vim.fn.undotree().seq_cur] = api.nvim_win_get_cursor(0)
      if is_selected() then normal("<Esc>") end
      vim.cmd.undo()
      vim.cmd.startinsert()
    end
    local function redo()
      if not editable() then return end
      if is_selected() then normal("<Esc>") end
      vim.cmd.redo()
      local positions = redo_positions[api.nvim_get_current_buf()] or {}
      local cursor = positions[vim.fn.undotree().seq_cur] or api.nvim_win_get_cursor(0)
      insert_at(math.min(cursor[1], api.nvim_buf_line_count(0)), cursor[2])
    end
    local function find()
      if not editable() then return end
      require("telescope.builtin").current_buffer_fuzzy_find({ prompt_title = "Find in current file" })
    end
    local function replace()
      if not editable() then return end
      local buf, win = api.nvim_get_current_buf(), api.nvim_get_current_win()
      vim.ui.input({ prompt = "Find text (literal): " }, function(pattern)
        if not pattern or pattern == "" then return end
        vim.ui.input({ prompt = "Replace with: " }, function(replacement)
          if replacement == nil or not api.nvim_win_is_valid(win) or api.nvim_win_get_buf(win) ~= buf then return end
          api.nvim_set_current_win(win)
          if not editable(buf) then return end
          vim.cmd.stopinsert()
          normal("<Esc>")
          local command = "%s/\\V" .. vim.fn.escape(pattern, [[\/]]) .. "/"
            .. vim.fn.escape(replacement, [[\/&~]]) .. "/gc"
          local ok, err = pcall(vim.cmd, command)
          if not ok then vim.notify(tostring(err), vim.log.levels.INFO) end
          if api.nvim_get_current_buf() == buf then vim.cmd.startinsert() end
        end)
      end)
    end

    local commands = {
      VimSelectAll = select_all, VimCopy = copy, VimCut = cut, VimPaste = paste,
      VimUndo = undo, VimRedo = redo, VimFind = find, VimReplace = replace,
    }
    for name, action in pairs(commands) do api.nvim_create_user_command(name, action, {}) end

    local function map(mode, lhs, rhs, desc, buf)
      vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = buf })
    end
    local command_keys = {
      { "<C-s>", "VimSave", "Save file" },
      { "<C-S-s>", "VimSaveAs", "Save file as" },
      { "<C-n>", "VimNewFile", "New file" },
      { "<C-o>", "VimOpenFile", "Open file" },
      { "<C-S-p>", "VimCommands", "Command palette" },
      { "<C-w>", "VimCloseBuffer", "Close file" },
      { "<C-Tab>", "VimNextBuffer", "Next file tab" },
      { "<C-S-Tab>", "VimPreviousBuffer", "Previous file tab" },
    }
    for _, binding in ipairs(command_keys) do
      map({ "n", "i", "x" }, binding[1], "<Cmd>" .. binding[2] .. "<CR>", binding[3])
      map("s", binding[1], "<Esc><Cmd>" .. binding[2] .. "<CR>", binding[3])
    end
    local selected_keys = {
      { "<C-p>", "VimOpenFile" },
      { "<C-b>", "Neotree toggle source=last position=left" },
      { "<M-1>", "Neotree focus filesystem left" },
      { "<M-2>", "Neotree focus git_status left" },
      { "<M-3>", "Neotree focus buffers left" },
      { "<F1>", "VimHelp" },
    }
    for _, binding in ipairs(selected_keys) do
      map("s", binding[1], "<Esc><Cmd>" .. binding[2] .. "<CR>", "Open editor control")
    end
    map("s", "<C-S-f>", function()
      normal("<Esc>")
      require("telescope.builtin").live_grep()
    end, "Search project")
    local function zoom(amount)
      vim.g.neovide_scale_factor = math.max(0.5, math.min(3, (vim.g.neovide_scale_factor or 1) + amount))
    end
    for _, key in ipairs({ "<C-+>", "<C-=>", "<C-S-=>" }) do
      map({ "n", "i", "x", "s" }, key, function() zoom(0.1) end, "Zoom in")
    end
    map({ "n", "i", "x", "s" }, "<C-->", function() zoom(-0.1) end, "Zoom out")
    map({ "n", "i", "x", "s" }, "<C-0>", function() vim.g.neovide_scale_factor = 1 end, "Reset zoom")

    local function configure_buffer(buf)
      if not editable(buf) or vim.b[buf].rflxn_gui_keys then return end
      vim.b[buf].rflxn_gui_keys = true
      map({ "n", "i", "x", "s" }, "<C-a>", select_all, "Select all", buf)
      map({ "i", "x", "s" }, "<C-c>", copy, "Copy", buf)
      map({ "i", "x", "s" }, "<C-x>", cut, "Cut", buf)
      map({ "n", "i", "x", "s" }, "<C-v>", paste, "Paste", buf)
      map({ "n", "x", "s" }, "<C-z>", undo, "Undo", buf)
      map("i", "<C-z>", "<C-G>u<Cmd>VimUndo<CR>", "Undo", buf)
      map({ "n", "x", "s" }, "<C-y>", redo, "Redo", buf)
      map("i", "<C-y>", redo, "Redo", buf)
      map({ "n", "x", "s" }, "<C-S-z>", redo, "Redo", buf)
      map("i", "<C-S-z>", redo, "Redo", buf)
      map({ "n", "i", "x" }, "<C-f>", find, "Find in file", buf)
      map("s", "<C-f>", "<Esc><Cmd>VimFind<CR>", "Find in file", buf)
      map({ "n", "i", "x" }, "<C-h>", replace, "Replace in file", buf)
      map("s", "<C-h>", "<Esc><Cmd>VimReplace<CR>", "Replace in file", buf)
      map({ "n", "i" }, "<F12>", function() require("telescope.builtin").lsp_definitions() end, "Go to definition", buf)
      map({ "n", "i" }, "<S-F12>", function() require("telescope.builtin").lsp_references() end, "Find references", buf)
      map({ "n", "i" }, "<F2>", vim.lsp.buf.rename, "Rename symbol", buf)
      map({ "n", "i" }, "<C-.>", vim.lsp.buf.code_action, "Code action", buf)
      map({ "n", "i" }, "<M-S-f>", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end, "Format file", buf)
      map("x", "<BS>", '"_c', "Delete selection", buf)
      map("s", "<BS>", '<C-G>"_c', "Delete selection", buf)
      map("x", "<Del>", '"_c', "Delete selection", buf)
      map("s", "<Del>", '<C-G>"_c', "Delete selection", buf)
    end

    local group = api.nvim_create_augroup("RflxnGuiEditing", { clear = true })
    api.nvim_create_autocmd({ "BufEnter", "WinEnter", "UIEnter" }, {
      group = group,
      callback = function()
        local buf, win = api.nvim_get_current_buf(), api.nvim_get_current_win()
        configure_buffer(buf)
        vim.schedule(function()
          if api.nvim_get_current_win() == win and api.nvim_get_current_buf() == buf
            and editable(buf) and vim.fn.mode() == "n" then
            vim.cmd.startinsert()
          end
        end)
      end,
    })
    configure_buffer(api.nvim_get_current_buf())
  end
end
