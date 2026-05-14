-- oil.nvim: edit filesystem like a buffer.
-- lazy=false нужен чтобы перехватывать `nvim <dir>` как file explorer (заменяет netrw).
return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
      { "<leader>e", "<cmd>Oil<cr>", desc = "Oil file explorer" },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
    },
  },

  -- Снимаем дефолтные биндинги LazyVim для neo-tree на <leader>e/<leader>E,
  -- чтобы oil не конфликтовал. neo-tree остаётся доступен через <leader>fe / <leader>fE.
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
}
