local home = os.getenv("HOME")
local xpm_path = home .. "/.local/share/xplr/dtomvan/xpm.xplr"
local xpm_url = "https://github.com/dtomvan/xpm.xplr"

package.path = package.path
  .. ";"
  .. xpm_path
  .. "/?.lua;"
  .. xpm_path
  .. "/?/init.lua"

os.execute(
  string.format(
    "[ -e '%s' ] || git clone '%s' '%s'",
    xpm_path,
    xpm_url,
    xpm_path
  )
)

require("xpm").setup({
  plugins = {
    -- Let xpm manage itself
    'dtomvan/xpm.xplr',
    { name = 'sayanarijit/fzf.xplr' },
    'sayanarijit/xclip.xplr',
    -- icon
    'prncss-xyz/icons.xplr',
    { 'dtomvan/extra-icons.xplr',
      after = function()
        xplr.config.general.table.row.cols[2] = { format = "custom.icons_dtomvan_col_1" }
      end
    },
    'sayanarijit/qrcp.xplr',
  },
  auto_install = true,
  auto_cleanup = true,
})

require("xclip").setup{
  copy_command = "xclip-copyfile",
  copy_paths_command = "xclip -sel clip",
  paste_command = "xclip-pastefile",
  keep_selection = false,
}

require"icons".setup()

require("qrcp").setup{
  mode = "action",
  key = "Q",
  send_options = "-i wlp2s0",
  receive_options = "-i wlp2s0",
}