{ enableGui ? true }:
{ pkgs, lib, username, ... }:
{
  fonts.packages = lib.optionals enableGui [ pkgs.nerd-fonts.jetbrains-mono ];

  home-manager.users.${username} = { config, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = false;
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
      waylandSupport = true;

      # Nix owns plugins, parsers and language tools; no runtime installers.
      plugins = with pkgs.vimPlugins; [
        neo-tree-nvim
        nui-nvim
        plenary-nvim
        nvim-web-devicons
        telescope-nvim
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        luasnip
        cmp_luasnip
        gitsigns-nvim
        lualine-nvim
        mini-bufremove
        dressing-nvim
        which-key-nvim
        toggleterm-nvim
        octo-nvim
        nvim-lspconfig
        conform-nvim
        tokyonight-nvim
        (nvim-treesitter.withPlugins (parsers: with parsers; [
          bash c cpp css go html java javascript json lua luadoc
          markdown markdown_inline nix python query regex rust
          toml tsx typescript vim vimdoc xml yaml
        ]))
      ];

      # Append to the editor's PATH so a project's devShell can take priority.
      extraPackages = with pkgs; [
        git
        gh
        lazygit
        ripgrep
        fd
        nodejs_24
        python3
        typescript-language-server
        basedpyright
        ruff
        jdt-language-server
        nixd
        lua-language-server
        bash-language-server
        vscode-langservers-extracted
        clang-tools
        rust-analyzer
        gopls
        prettier
        stylua
        nixfmt
        shfmt
      ];

      initLua = lib.concatStringsSep "\n" [
        (builtins.readFile ./init.lua)
        (builtins.readFile ./layout.lua)
        (builtins.readFile ./gui.lua)
      ];
    };

    programs.neovide = lib.mkIf enableGui {
      enable = true;
      settings = {
        neovim-bin = "${config.programs.neovim.finalPackage}/bin/nvim";
        fork = true;
        # File tabs are buffers in the shared editor layout.
        tabs = false;
      };
    };
  };
}
