-- Kanagawa как дефолтная тема (вместо tokyonight из LazyVim starter).
return {
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
