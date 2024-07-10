require'nvim-treesitter.configs'.setup {
    ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = { "phpdoc", "tree-sitter-phpdoc" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
  },
  -- refactor = {
  --   -- highlight_current_scope = { enable = true },
  --   highlight_definitions = { enable = true },
  --   smart_rename = {
  --     enable = true,
  --     keymaps = {
  --       smart_rename = "grr",
  --     },
  --   },
  -- },
}
