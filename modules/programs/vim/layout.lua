-- Desktop-style chrome, shared by the GUI and terminal UI.
do
  local api = vim.api
  local last_editor
  local function is_editor(win)
    if not win or not api.nvim_win_is_valid(win) then return false end
    local buf = api.nvim_win_get_buf(win)
    return vim.bo[buf].buftype == "" and vim.fn.isdirectory(api.nvim_buf_get_name(buf)) == 0
  end
  local function editor()
    if is_editor(api.nvim_get_current_win()) then return api.nvim_get_current_win() end
    if is_editor(last_editor) and api.nvim_win_get_tabpage(last_editor) == api.nvim_get_current_tabpage() then
      api.nvim_set_current_win(last_editor)
      return last_editor
    end
    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
      if is_editor(win) then api.nvim_set_current_win(win); return win end
    end
    vim.cmd("botright vnew")
    return api.nvim_get_current_win()
  end
  api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    callback = function() if is_editor(api.nvim_get_current_win()) then last_editor = api.nvim_get_current_win() end end,
  })

  require("mini.bufremove").setup({})
  require("dressing").setup({
    input = { relative = "editor", border = "rounded", prefer_width = 60 },
    select = { backend = { "builtin" }, builtin = {
      relative = "editor", border = "rounded", min_height = 3,
      mappings = { ["<2-LeftMouse>"] = "Confirm" },
      override = function(conf) vim.cmd.stopinsert(); return conf end,
    } },
  })

  local function save(buf, save_as, done)
    local function write(path)
      if not api.nvim_buf_is_valid(buf) then return end
      local ok, err = pcall(api.nvim_buf_call, buf, function()
        if path then vim.cmd.saveas({ args = { vim.fn.expand(path) } }) else vim.cmd.write() end
      end)
      if not ok then vim.notify(tostring(err), vim.log.levels.ERROR); return end
      if done then done() end
    end
    local name = api.nvim_buf_get_name(buf)
    if name ~= "" and not save_as then write(); return end
    vim.ui.input({ prompt = "Save file as: ", default = name ~= "" and name or (vim.fn.getcwd() .. "/"), completion = "file" }, function(path)
      if path and path ~= "" then write(path) end
    end)
  end
  local function close_buffer(buf)
    buf = buf or api.nvim_win_get_buf(editor())
    local function discard()
      if api.nvim_buf_is_valid(buf) then require("mini.bufremove").delete(buf, true) end
    end
    if not vim.bo[buf].modified then discard(); return end
    local name = vim.fn.fnamemodify(api.nvim_buf_get_name(buf), ":t")
    vim.ui.select({ "Save", "Discard changes", "Cancel" }, {
      prompt = "Save changes to " .. (name ~= "" and name or "Untitled") .. "?",
    }, function(choice)
      if choice == "Save" then save(buf, false, discard)
      elseif choice == "Discard changes" then discard() end
    end)
  end
  local function files()
    return vim.tbl_filter(function(buf)
      return vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.fn.isdirectory(api.nvim_buf_get_name(buf)) == 0
    end, api.nvim_list_bufs())
  end
  local function cycle(step)
    editor()
    local buffers = files()
    for i, buf in ipairs(buffers) do
      if buf == api.nvim_get_current_buf() then
        api.nvim_set_current_buf(buffers[(i - 1 + step) % #buffers + 1])
        return
      end
    end
  end
  local function open_folder()
    vim.ui.input({ prompt = "Open folder: ", default = vim.fn.getcwd() .. "/", completion = "dir" }, function(path)
      if not path then return end
      path = vim.fn.expand(path)
      if vim.fn.isdirectory(path) == 0 then vim.notify("Folder does not exist: " .. path, vim.log.levels.ERROR); return end
      vim.cmd.cd({ args = { path } })
      require("neo-tree.command").execute({ action = "show", source = "filesystem", position = "left", dir = path })
    end)
  end
  local commands = {
    VimSave = function() save(api.nvim_win_get_buf(editor()), false) end,
    VimSaveAs = function() save(api.nvim_win_get_buf(editor()), true) end,
    VimNewFile = function() editor(); vim.cmd.enew() end,
    VimOpenFile = function() editor(); require("telescope.builtin").find_files({ hidden = true }) end,
    VimOpenFolder = open_folder,
    VimCloseBuffer = function() close_buffer() end,
    VimNextBuffer = function() cycle(1) end,
    VimPreviousBuffer = function() cycle(-1) end,
  }
  for name, action in pairs(commands) do api.nvim_create_user_command(name, action, {}) end

  local function command(cmd) return function() vim.cmd(cmd) end end
  local function item(label, cmd, key) return { label = label, run = type(cmd) == "string" and command(cmd) or cmd, key = key } end
  local menu_selection
  local function editing(cmd, fallback, selection)
    return function()
      if selection and menu_selection == api.nvim_get_current_buf() then vim.cmd("normal! gv") end
      if vim.fn.exists(":" .. cmd) == 2 then vim.cmd(cmd) elseif fallback then vim.cmd(fallback) end
    end
  end
  local menus = {
    { name = "File", items = {
      item("New File", "VimNewFile", "Ctrl+N"), item("Open File…", "VimOpenFile", "Ctrl+O"),
      item("Open Folder…", "VimOpenFolder"), item("Save", "VimSave", "Ctrl+S"),
      item("Save As…", "VimSaveAs", "Ctrl+Shift+S"), item("Close File", "VimCloseBuffer", "Ctrl+W"),
      item("Quit", "confirm qall"),
    } },
    { name = "Edit", items = {
      item("Undo", editing("VimUndo", "undo"), "Ctrl+Z"), item("Redo", editing("VimRedo", "redo"), "Ctrl+Y"),
      item("Cut", editing("VimCut", 'normal! "+dd', true), "Ctrl+X"),
      item("Copy", editing("VimCopy", 'normal! "+yy', true), "Ctrl+C"),
      item("Paste", editing("VimPaste", 'normal! "+p', true), "Ctrl+V"),
      item("Select All", editing("VimSelectAll", "normal! ggVG"), "Ctrl+A"),
      item("Find in File", function()
        if vim.fn.exists(":VimFind") == 2 then vim.cmd.VimFind() else require("telescope.builtin").current_buffer_fuzzy_find() end
      end, "Ctrl+F"),
      item("Replace in File", function()
        if vim.fn.exists(":VimReplace") == 2 then vim.cmd.VimReplace() end
      end, "Ctrl+H"),
      item("Search Project", function() require("telescope.builtin").live_grep() end, "Ctrl+Shift+F"),
    } },
    { name = "View", items = {
      item("Files", "Neotree filesystem left", "Alt+1"), item("Git Changes", "Neotree git_status left", "Alt+2"),
      item("Open Files", "Neotree buffers left", "Alt+3"), item("Toggle Sidebar", "Neotree toggle source=last position=left", "Ctrl+B"),
      item("Terminal", "ToggleTerm", "Ctrl+\\"),
      item("Split Editor Right", "vsplit"), item("Split Editor Down", "split"),
      item("Zoom In", function() if vim.g.neovide then vim.g.neovide_scale_factor = math.min(3, (vim.g.neovide_scale_factor or 1) + 0.1) end end, "Ctrl++"),
      item("Zoom Out", function() if vim.g.neovide then vim.g.neovide_scale_factor = math.max(0.5, (vim.g.neovide_scale_factor or 1) - 0.1) end end, "Ctrl+-"),
    } },
    { name = "Go", items = {
      item("Go to File", "VimOpenFile", "Ctrl+P"),
      item("Go to Definition", function() require("telescope.builtin").lsp_definitions() end, "F12"),
      item("Find References", function() require("telescope.builtin").lsp_references() end, "Shift+F12"),
      item("Document Symbols", function() require("telescope.builtin").lsp_document_symbols() end),
      item("Next File", "VimNextBuffer", "Ctrl+Tab"), item("Previous File", "VimPreviousBuffer", "Ctrl+Shift+Tab"),
    } },
    { name = "Code", items = {
      item("Rename Symbol", vim.lsp.buf.rename, "F2"), item("Code Actions", vim.lsp.buf.code_action, "Ctrl+."),
      item("Format File", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, "Alt+Shift+F"),
      item("Show Documentation", vim.lsp.buf.hover),
      item("Problems", function() require("telescope.builtin").diagnostics() end),
    } },
    { name = "Git", items = {
      item("Changes Sidebar", "Neotree git_status left"), item("Git Interface", "VimGit", "Space g g"),
      item("Preview Change", function() require("gitsigns").preview_hunk() end),
      item("Stage Change", function() require("gitsigns").stage_hunk() end),
      item("Blame Line", function() require("gitsigns").blame_line() end),
      item("GitHub Pull Requests", "Octo pr list"), item("GitHub Issues", "Octo issue list"),
    } },
    { name = "Help", items = {
      item("Getting Started", "VimHelp", "F1"), item("Command Palette", "VimCommands", "Ctrl+Shift+P"),
      item("Key Bindings", function() require("which-key").show({}) end), item("Vim Tutorial", "Tutor"),
    } },
  }
  local function run(action)
    vim.schedule(function()
      editor()
      local ok, err = pcall(action)
      menu_selection = nil
      if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
    end)
  end
  api.nvim_create_user_command("VimCommands", function()
    local actions = {}
    for _, menu in ipairs(menus) do
      for _, entry in ipairs(menu.items) do
        table.insert(actions, { label = menu.name .. ": " .. entry.label, run = entry.run })
      end
    end
    require("telescope.pickers").new({}, {
      prompt_title = "Commands",
      finder = require("telescope.finders").new_table({ results = actions, entry_maker = function(entry)
        return { value = entry, display = entry.label, ordinal = entry.label }
      end }),
      sorter = require("telescope.config").values.generic_sorter({}),
      attach_mappings = function(buf)
        require("telescope.actions").select_default:replace(function()
          local selected = require("telescope.actions.state").get_selected_entry()
          require("telescope.actions").close(buf)
          if selected then run(selected.value.run) end
        end)
        return true
      end,
    }):find()
  end, {})
  vim.keymap.set({ "n", "i", "x" }, "<F4>", "<Cmd>VimCommands<CR>", { silent = true, desc = "Command palette" })
  vim.keymap.set("s", "<F4>", "<Esc><Cmd>VimCommands<CR>", { silent = true, desc = "Command palette" })

  local active_menu
  local function open_menu(menu)
    menu_selection = nil
    if vim.fn.mode():match("^[vV\22sS\19]") then
      menu_selection = api.nvim_get_current_buf()
      vim.cmd.normal({ args = { api.nvim_replace_termcodes("<Esc>", true, false, true) }, bang = true })
    end
    vim.schedule(function()
      if active_menu then active_menu:unmount() end
      vim.cmd.stopinsert()
      local Menu = require("nui.menu")
      local entries = vim.tbl_map(function(entry)
        local label = entry.label .. string.rep(" ", math.max(2, 25 - vim.fn.strdisplaywidth(entry.label))) .. (entry.key or "")
        return Menu.item(label, { action = entry.run })
      end, menu.items)
      local popup = Menu({
        relative = "editor", position = { row = 2, col = menu.col },
        border = { style = "rounded", text = { top = menu.name, top_align = "left" } },
        win_options = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder", cursorline = true },
      }, {
        lines = entries, max_width = 44,
        on_submit = function(entry) run(entry.action) end,
      })
      active_menu = popup
      popup:mount()
      popup:map("n", "<LeftMouse>", function()
        local pos = vim.fn.getmousepos()
        if pos.winid ~= popup.winid then popup:unmount(); return end
        local entry = popup.tree:get_node(pos.line)
        if entry then popup:unmount(); run(entry.action) end
      end, { noremap = true })
      popup:on("BufLeave", function() popup:unmount() end, { once = true })
    end)
  end
  local menu_components, col = {}, 0
  for _, menu in ipairs(menus) do
    menu.col = col
    col = col + #menu.name + 2
    table.insert(menu_components, {
      function() return menu.name end, on_click = function() open_menu(menu) end, padding = 1,
      color = { fg = "#c0caf5", bg = "#1f2335" },
    })
  end
  local tabs = { "buffers", mode = 0, show_filename_only = false,
    symbols = { modified = " ●", alternate_file = "" },
    max_length = function() return math.max(10, api.nvim_win_get_width(0) - 5) end,
    buffers_color = { active = { fg = "#c0caf5", bg = "#3b4261", gui = "bold" }, inactive = { fg = "#a9b1d6", bg = "#1f2335" } },
  }
  local winbar = {
    lualine_a = {}, lualine_b = {}, lualine_c = { tabs }, lualine_x = {}, lualine_y = {},
    lualine_z = { { function() return "×" end, on_click = function() run(commands.VimCloseBuffer) end,
      padding = 1, color = { fg = "#c0caf5", bg = "#1f2335" },
    } },
  }
  vim.opt.showtabline = 2
  vim.opt.showmode = false
  require("lualine").setup({
    options = {
      theme = "tokyonight", globalstatus = true, component_separators = "", section_separators = "",
      disabled_filetypes = { winbar = { "neo-tree", "NvimTree", "TelescopePrompt", "help", "qf", "toggleterm", "DressingInput", "DressingSelect" } },
    },
    sections = {
      lualine_a = { "mode" }, lualine_b = { "branch", "diff" }, lualine_c = { { "filename", path = 1 }, "diagnostics" },
      lualine_x = { "encoding", "filetype" }, lualine_y = { "progress" }, lualine_z = { "location" },
    },
    tabline = { lualine_a = {}, lualine_b = menu_components, lualine_c = {}, lualine_x = {}, lualine_y = {}, lualine_z = {} },
    winbar = winbar, inactive_winbar = winbar,
  })
end
