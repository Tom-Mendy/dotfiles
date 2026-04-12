return {
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  opts = function(_, opts)
    local previous_on_attach = opts.on_attach
    opts.on_attach = function(bufnr)
      if previous_on_attach then
        previous_on_attach(bufnr)
      end

      vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
        { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
      vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk,
        { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
      vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk,
        { buffer = bufnr, desc = '[P]review [H]unk' })
    end
  end,
}
