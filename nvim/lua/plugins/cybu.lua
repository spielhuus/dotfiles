return {
  "ghillb/cybu.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local ok, cybu = pcall(require, "cybu")
    if not ok then
      return
    end
    cybu.setup()
    vim.keymap.set("n", "<C-h>", "<Plug>(CybuPrev)")
    vim.keymap.set("n", "<C-l>", "<Plug>(CybuNext)")
    vim.keymap.set({ "n", "v" }, "<c-s-tab>", "<plug>(CybuLastusedPrev)")
    vim.keymap.set({ "n", "v" }, "<c-tab>", "<plug>(CybuLastusedNext)")
  end,
}
