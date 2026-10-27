NeNe Swarm @VERSION@ (Linux x86_64)
===================================

A terminal screensaver in which a hand-written AI pilot plays a fixed-screen shooter forever:
a marching swarm that dives at you, breakable shields, a capture beam, a bonus saucer, bonus stages
and a top-five high score. Title, play, game over, and around again until you press q.
Four pilots (BLASTER.BIN, NERVOUS.TMP, LUCKY.INI, SNIPER.ISO) take turns and talk in the COMMS panel.

Requirements: Linux on x86_64 with glibc 2.35 or newer (Ubuntu 22.04 or later),
for example Ubuntu on WSL2 in Windows Terminal. Swift is not needed (the standard library is linked statically).

Download and verify
-------------------
1. Download these two files from the GitHub Release into one folder:
     nene-swarm-@VERSION@-linux-x86_64.tar.gz
     SHA256SUMS
2. Verify (it must say OK):
     sha256sum --check SHA256SUMS
3. Extract and run:
     tar -xzf nene-swarm-@VERSION@-linux-x86_64.tar.gz
     ./nene-swarm-@VERSION@-linux-x86_64/nene-swarm

Keys
----
  q   quit
  t   next color theme (12 themes)
  d   next difficulty (EASY, NORMAL, HARD); it applies at once

Options
-------
  --theme NAME            NEON PHOSPHOR AMBER SYNTHWAVE GLACIER BLOODMOON VAPOR MONO TOXIC GILDED ABYSS PAPER
  --difficulty NAME       easy, normal (default) or hard
  --seed N                the same seed gives the same games and the same lines (if you press no keys)
  --tick-rate N           game steps per second, 10 to 60 (default 30)
  --title-pause SEC       time on the title screen (default 5)
  --game-over-pause SEC   time on the game over screen (default 4)
  --version               print the version and exit

The terminal must be at least 80x24. At 100x26 or larger the HUD is wider and shows two lines of COMMS.
High scores are kept in $XDG_STATE_HOME/nene-swarm/highscores.txt (or ~/.local/state/nene-swarm/).

License: MIT (see LICENSE)
Source: https://github.com/hideyukiMORI/nene-swarm
