-- Neogen: A better annotation generator. Supports multiple languages and annotation conventions.
-- https://github.com/danymat/neogen
return({
    "danymat/neogen",
    enabled = false,
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("neogen").setup {
        snippet_engine = "luasnip",
        enabled = true,
        languages = {
          lua = {
            template = {
              annotation_convention = "ldoc",
            },
          },
          python = {
            template = {
              annotation_convention = "google_docstrings",
            },
          },
          rust = {
            template = {
              annotation_convention = "rustdoc",
            },
          },
          javascript = {
            template = {
              annotation_convention = "jsdoc",
            },
          },
          typescript = {
            template = {
              annotation_convention = "tsdoc",
            },
          },
          typescriptreact = {
            template = {
              annotation_convention = "tsdoc",
            },
          },
        },
      }
    end
})
