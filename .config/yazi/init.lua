-- $ ya pack -a luccahuguet/auto-layout
require("auto-layout").setup({
  breakpoint_large = 110, -- new large window threshold, defaults to 100
  breakpoint_medium = 60, -- new medium window threshold, defaults to 50
})

-- configuration of git plugin
th.git = th.git or {}
th.git.modified_sign = "M"
th.git.deleted_sign = "D"
th.git.added_sign = "A"
th.git.untracked_sign = "*"
th.git.ignored_sign = "I"
th.git.updated_sign = "U"

-- $ ya pkg add yazi-rs/plugins:git
require("git"):setup()
