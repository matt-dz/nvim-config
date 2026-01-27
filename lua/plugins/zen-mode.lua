return {
  "folke/zen-mode.nvim",
  keys = {
    { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
  },
  opts = {
    window = {
      width = 120,
      options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
      },
    },
    plugins = {
      tmux = { enabled = true },
      twilight = { enabled = false },
    },
  },
}
