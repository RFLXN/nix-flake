-- Plugins, parsers and language tools are supplied by Nix.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
opt.number = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 500
opt.scrolloff = 5
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true
vim.cmd.colorscheme("tokyonight-night")

if vim.g.neovide then
  opt.guifont = "JetBrainsMono Nerd Font:h12"
  vim.g.neovide_input_ime = true
end

local function map(mode, lhs, rhs, desc, bufnr)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr })
end

local function show_help()
  local lines = vim.g.neovide and {
    "Neovide GUI 시작 안내",
    "",
    "파일을 열면 바로 입력할 수 있습니다. 마우스와 방향키도 사용할 수 있습니다.",
    "Esc: Vim 일반 모드로 전환    i: 다시 입력",
    "",
    "상단 메뉴를 클릭하거나 Ctrl-Shift-P 또는 F4로 명령을 검색하세요.",
    "파일 탭을 클릭하면 전환됩니다. 오른쪽 ×는 현재 파일을 닫습니다.",
    "왼쪽 Files / Git / Open에서 파일 트리·변경 사항·열린 파일을 선택하세요.",
    "",
    "Ctrl-N / Ctrl-O          새 파일 / 파일 열기",
    "Ctrl-S / Ctrl-Shift-S    저장 / 다른 이름으로 저장",
    "Ctrl-W / Ctrl-Tab        현재 파일 닫기 / 다음 파일",
    "Ctrl-A / Shift+방향키    전체 선택 / 범위 선택",
    "Ctrl-C / Ctrl-X / Ctrl-V 복사 / 잘라내기 / 붙여넣기",
    "Ctrl-Z / Ctrl-Y          실행 취소 / 다시 실행",
    "Ctrl-F / Ctrl-H          파일 내 검색 / 바꾸기",
    "Ctrl-P / Ctrl-Shift-F    파일 찾기 / 프로젝트 내용 검색",
    "Ctrl-B / Alt-1·2·3       사이드바 열기·닫기 / Files·Git·Open 선택",
    "Ctrl-\\                  하단 터미널 열기·닫기",
    "F12 / Shift-F12 / F2     정의 / 참조 / 이름 변경",
    "Ctrl-. / Alt-Shift-F     코드 액션 / 파일 포맷",
    "Ctrl-+ / Ctrl-- / Ctrl-0 확대 / 축소 / 원래 크기",
    "",
    "Git 메뉴에서 Git 화면과 GitHub PR·이슈를 열 수 있습니다.",
    "GitHub는 gh auth login으로 로그인하세요. Octo에서 :w는 내용을 게시합니다.",
    "",
    "Esc 또는 q를 누르면 이 안내를 닫습니다. F1로 다시 열 수 있습니다.",
  } or {
    "Neovim 시작 안내",
    "",
    "i: 입력 시작    Esc: 일반 모드로 돌아가기",
    "방향키와 마우스를 사용할 수 있습니다. 아래 Space 조합은 일반 모드에서 누르세요.",
    "",
    "Ctrl-S                 저장",
    "Ctrl-P / Space f f     파일 찾기",
    "Ctrl-B / Space e       파일 트리 열기·닫기",
    "Ctrl-Shift-F / Space f g  프로젝트 내용 검색",
    "Space f b              열린 파일 목록",
    "Space t / Ctrl-\\       터미널 열기·닫기",
    "Space g g              Git 화면: diff, stage, commit, branch",
    "Space g p / Space g i  GitHub PR / 이슈 목록",
    "gd / gr / K            정의 / 참조 / 설명",
    "F2 / Space c a         이름 변경 / 코드 액션",
    "Space c f / Space c d  코드 포맷 / 진단 설명",
    "Ctrl-Space             자동완성 표시; 방향키로 선택 후 Enter",
    "Space ?                단축키 목록",
    "Space h t              Vim 실습 안내(:Tutor)",
    "",
    ":q + Enter: 창 닫기    :wq + Enter: 저장 후 닫기",
    "터미널에서는 Ctrl-\\를 누르면 편집 화면으로 돌아갑니다.",
    "GitHub는 gh auth login으로 로그인하세요. Octo에서 :w는 수정 내용을 게시합니다.",
    "프로젝트 폴더에서 neovide . 또는 nvim .으로 실행하세요.",
    "",
    "Esc 또는 q를 누르면 이 안내를 닫습니다. F1로 다시 열 수 있습니다.",
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  local width = math.max(1, math.min(90, vim.o.columns - 4))
  local height = math.max(1, math.min(#lines, vim.o.lines - 4))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", border = "rounded", style = "minimal",
    width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2), col = math.floor((vim.o.columns - width) / 2),
  })
  for _, key in ipairs({ "q", "<Esc>", "<F1>" }) do
    map("n", key, function() vim.api.nvim_win_close(win, true) end, "Close help", buf)
  end
end
vim.api.nvim_create_user_command("VimHelp", show_help, {})
map({ "n", "i" }, "<F1>", "<Esc><Cmd>VimHelp<CR>", "Getting started")
map("n", "<leader>hh", show_help, "Getting started")
map("n", "<leader>ht", "<Cmd>Tutor<CR>", "Vim tutorial")
map({ "n", "i", "v" }, "<C-s>", "<Cmd>write<CR>", "Save")
map("n", "<leader>w", "<Cmd>write<CR>", "Save")
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", "Clear search highlight")
map("n", "<S-h>", "<Cmd>bprevious<CR>", "Previous buffer")
map("n", "<S-l>", "<Cmd>bnext<CR>", "Next buffer")

require("which-key").setup({ delay = 400 })
require("which-key").add({
  { "<leader>f", group = "Find" }, { "<leader>g", group = "Git / GitHub" },
  { "<leader>c", group = "Code" }, { "<leader>h", group = "Help" },
})
map("n", "<leader>?", function() require("which-key").show({}) end, "Key bindings")
require("neo-tree").setup({
  close_if_last_window = false,
  window = { position = "left", width = 34 },
  source_selector = {
    winbar = true,
    statusline = false,
    content_layout = "center",
    tabs_layout = "equal",
    sources = {
      { source = "filesystem", display_name = " Files " },
      { source = "git_status", display_name = " Git " },
      { source = "buffers", display_name = " Open " },
    },
  },
  filesystem = {
    follow_current_file = { enabled = true },
    filtered_items = { hide_dotfiles = false, hide_gitignored = true },
    hijack_netrw_behavior = "open_default",
  },
})
map("n", "<leader>e", "<Cmd>Neotree toggle source=last position=left<CR>", "Toggle sidebar")
map({ "n", "i" }, "<C-b>", "<Esc><Cmd>Neotree toggle source=last position=left<CR>", "Toggle sidebar")
map({ "n", "i" }, "<M-1>", "<Esc><Cmd>Neotree focus filesystem left<CR>", "Files sidebar")
map({ "n", "i" }, "<M-2>", "<Esc><Cmd>Neotree focus git_status left<CR>", "Git sidebar")
map({ "n", "i" }, "<M-3>", "<Esc><Cmd>Neotree focus buffers left<CR>", "Open files sidebar")
require("telescope").setup({ defaults = { file_ignore_patterns = { "node_modules/", "%.git/" } } })
local telescope = require("telescope.builtin")
local function find_files() telescope.find_files({ hidden = true }) end
map("n", "<leader>ff", find_files, "Find files")
map({ "n", "i" }, "<C-p>", find_files, "Find files")
map("n", "<leader>fg", telescope.live_grep, "Search project")
map({ "n", "i" }, "<C-S-f>", telescope.live_grep, "Search project")
map("n", "<leader>fb", telescope.buffers, "Open buffers")
map("n", "<leader>fd", telescope.diagnostics, "Project diagnostics")
map("n", "<leader>fs", telescope.lsp_document_symbols, "Document symbols")

require("toggleterm").setup({
  open_mapping = [[<C-\>]], direction = "horizontal", size = 14,
  float_opts = { border = "rounded" },
})
map("n", "<leader>t", "<Cmd>ToggleTerm<CR>", "Terminal")
-- Keep terminal Escape available to shells and interactive programs.
local git_terminals = {}
local function open_git()
  local dir = vim.fs.root(0, ".git") or vim.fn.getcwd()
  if not git_terminals[dir] then
    git_terminals[dir] = require("toggleterm.terminal").Terminal:new({
      cmd = "lazygit", dir = dir, direction = "float", hidden = true,
    })
  end
  git_terminals[dir]:toggle()
end
vim.api.nvim_create_user_command("VimGit", open_git, {})
map("n", "<leader>gg", open_git, "Git interface")
require("octo").setup({ picker = "telescope", enable_builtin = true })
map("n", "<leader>gp", "<Cmd>Octo pr list<CR>", "GitHub pull requests")
map("n", "<leader>gi", "<Cmd>Octo issue list<CR>", "GitHub issues")
map("n", "<leader>go", "<Cmd>Octo<CR>", "GitHub actions")
require("gitsigns").setup({
  on_attach = function(buf)
    local gs = require("gitsigns")
    map("n", "]c", function() gs.nav_hunk("next") end, "Next Git change", buf)
    map("n", "[c", function() gs.nav_hunk("prev") end, "Previous Git change", buf)
    map("n", "<leader>gh", gs.preview_hunk, "Preview change", buf)
    map("n", "<leader>gs", gs.stage_hunk, "Stage hunk", buf)
    map("n", "<leader>gb", gs.blame_line, "Blame line", buf)
    map("n", "<leader>gd", gs.diffthis, "Diff against index", buf)
  end,
})

local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-n>"] = not vim.g.neovide and cmp.mapping.select_next_item() or nil,
    ["<Down>"] = cmp.mapping.select_next_item(),
    ["<Up>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(1) then luasnip.jump(1) else fallback() end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(-1) then luasnip.jump(-1) else fallback() end
    end, { "i", "s" }),
  },
  sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" }, { name = "path" } }, {
    { name = "buffer", keyword_length = 3 },
  }),
})
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier" }, javascriptreact = { "prettier" },
    typescript = { "prettier" }, typescriptreact = { "prettier" },
    json = { "prettier" }, jsonc = { "prettier" }, html = { "prettier" },
    css = { "prettier" }, yaml = { "prettier" }, markdown = { "prettier" },
    python = { "ruff_format" }, lua = { "stylua" }, nix = { "nixfmt" }, sh = { "shfmt" },
  },
})
map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, "Format code")

vim.diagnostic.config({
  severity_sort = true, underline = true, update_in_insert = false,
  virtual_text = { spacing = 2, source = "if_many" }, float = { border = "rounded", source = true },
})
map("n", "<leader>cd", vim.diagnostic.open_float, "Diagnostic details")
vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
vim.lsp.config("basedpyright", {
  settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
  before_init = function(_, config)
    -- GUI launches do not inherit a shell's activated virtualenv.
    local root = config.root_dir or vim.fn.getcwd()
    local python = vim.env.VIRTUAL_ENV and (vim.env.VIRTUAL_ENV .. "/bin/python") or (root .. "/.venv/bin/python")
    if vim.fn.executable(python) == 1 then
      config.settings.python = vim.tbl_extend("force", config.settings.python or {}, { pythonPath = python })
    end
  end,
})
vim.lsp.config("lua_ls", {
  settings = { Lua = { diagnostics = { globals = { "vim" } }, telemetry = { enable = false } } },
})
vim.lsp.config("jdtls", {
  cmd = function(dispatchers, config)
    -- Full-path hashing keeps identically named projects in separate workspaces.
    local root = config.root_dir or vim.fn.getcwd()
    local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.sha256(root)
    vim.fn.mkdir(workspace, "p")
    return vim.lsp.rpc.start({ "jdtls", "-configuration", workspace .. "/config", "-data", workspace }, dispatchers, {
      cwd = root, env = config.cmd_env, detached = config.detached,
    })
  end,
})
local servers = vim.g.rflxn_vim_servers or {
  "ts_ls", "basedpyright", "ruff", "jdtls", "nixd", "lua_ls", "bashls",
  "jsonls", "html", "cssls", "clangd", "rust_analyzer", "gopls",
}
vim.lsp.enable(servers)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.name == "ruff" then client.server_capabilities.hoverProvider = false end
    map("n", "gd", telescope.lsp_definitions, "Go to definition", event.buf)
    map("n", "gr", telescope.lsp_references, "Find references", event.buf)
    map("n", "K", vim.lsp.buf.hover, "Documentation", event.buf)
    map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol", event.buf)
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol", event.buf)
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action", event.buf)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
    if lang and #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) > 0 then
      vim.treesitter.start(event.buf, lang)
    end
  end,
})
local sidebar_started = false
vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter" }, {
  callback = function()
    vim.schedule(function()
      if sidebar_started or vim.v.vim_did_enter == 0 or #vim.api.nvim_list_uis() == 0 then return end
      sidebar_started = true
      local first_arg = vim.fn.argv(0)
      local dir = vim.fn.getcwd()
      if first_arg ~= "" and first_arg ~= "-" then
        local path = vim.fn.fnamemodify(first_arg, ":p")
        dir = vim.fn.isdirectory(path) == 1 and path
          or vim.fs.root(path, ".git") or vim.fn.fnamemodify(path, ":h")
      end
      require("neo-tree.command").execute({
        action = "show", source = "filesystem", position = "left", dir = dir,
      })
    end)
  end,
})
