return {
  -- Monokai (Lua rewrite, recommended for Neovim)
  {
    "tanvirtin/monokai.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("monokai")
      -- variants also available: "monokai_pro", "monokai_soda", "monokai_ristretto"
    end,
  }
}
