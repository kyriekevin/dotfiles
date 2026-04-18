-- Yazi init — runs once at launch before the first render.
--
-- Boot-order matters: plugins loaded here must be installed via `ya pkg`
-- first (see .chezmoiscripts/run_onchange_after_40-yazi-plugins.sh).
-- Order inside this file is cosmetic → doesn't affect correctness.

-- full-border: draw rounded borders around parent/current/preview columns.
-- Purely visual polish. If you dislike the aesthetic, delete this line
-- and the borders vanish immediately.
require("full-border"):setup()

-- git: decorate files with git status glyphs (M/A/D/?/!) in the left gutter
-- of the current column. The fetcher registered in yazi.toml
-- ([plugin.prepend_fetchers]) drives the data; this line activates the
-- status linemode + sets its render order. 1500 is the plugin's own
-- recommended default (drops it between yazi's built-in size linemode
-- and user-space linemodes).
require("git"):setup({ order = 1500 })
