return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>g", group = "Git", mode = { "n", "v" } },
      { "<leader>h", group = "Hunks", mode = { "n", "v" } },
      { "<leader>t", group = "Toggles" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Show buffer-local keybindings",
    },
  },
}
