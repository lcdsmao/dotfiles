UsePlugin 'mini.diff'

lua << EOF
local diff = require("mini.diff")
diff.setup({
  -- Disabled by default
  source = diff.gen_source.none(),
})
EOF

