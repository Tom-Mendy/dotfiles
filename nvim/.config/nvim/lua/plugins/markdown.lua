return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
      checkbox = {
        enabled = true,
      },
    },
  },
}
