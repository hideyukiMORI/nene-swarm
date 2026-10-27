# NeNe Swarm

> *An AI pilot plays a fixed shooter in your terminal. Forever. Press `q` to make it stop.*

A terminal screensaver in which a hand-written AI pilot flies against a marching, diving swarm: breakable shields, a capture beam,
a bonus saucer, bonus stages and a top-five high score. Title, play, game over, and around again.
Four pilots take turns, and each one grumbles, jokes and gloats in its own voice the whole time. You don't have to do anything.

[![release](https://img.shields.io/github/v/release/hideyukiMORI/nene-swarm)](https://github.com/hideyukiMORI/nene-swarm/releases/latest)
![platform](https://img.shields.io/badge/platform-Linux%20x86__64%20%2F%20WSL2-555)
![license](https://img.shields.io/badge/license-MIT-555)

**English** · [日本語](README.ja.md)

It is a sibling of [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit) (chess), [NeNe Reversi](https://github.com/hideyukiMORI/nene-reversi),
[NeNe Igo](https://github.com/hideyukiMORI/nene-igo) (Go) and [NeNe Poker](https://github.com/hideyukiMORI/nene-poker).

🧪 **Beta.** [v0.1.0](https://github.com/hideyukiMORI/nene-swarm/releases/tag/v0.1.0) is out as a beta: it has not yet been checked by eye in Windows Terminal, and screenshots will follow.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/hideyukiMORI/nene-swarm/main/install.sh | bash
```

This downloads the latest release, verifies it against `SHA256SUMS`, and only then installs it as `~/.local/bin/nene-swarm`.
If the checksum doesn't match, nothing is installed. The whole script is [install.sh](install.sh), about 45 lines.

- Requirements: Linux on x86_64 with glibc 2.35 or newer (Ubuntu 22.04+). Made for Ubuntu under WSL2 with Windows Terminal
- No Swift needed. It is a single file with the Swift standard library linked statically; the only dynamic dependencies are libc, libm, libstdc++ and libgcc_s
- To uninstall: `rm ~/.local/bin/nene-swarm` (and `~/.local/state/nene-swarm` for the high scores)

**From PowerShell** (Windows, with WSL):

```powershell
irm https://raw.githubusercontent.com/hideyukiMORI/nene-swarm/main/install.ps1 | iex
```

It runs the same installer inside your default WSL distribution, then puts a small `nene-swarm.cmd` in `%LOCALAPPDATA%\nene-swarm\bin` and adds that folder to your user PATH,
so `nene-swarm` works from PowerShell and cmd too. Set `NENE_SWARM_DISTRO` to use another distribution.
To uninstall: delete `%LOCALAPPDATA%\nene-swarm`, remove it from your PATH, and run `wsl rm ~/.local/bin/nene-swarm`

## How to watch

```bash
nene-swarm
```

| Key | |
| --- | --- |
| `q` | Quit (Ctrl+C works too; however it ends, your terminal is restored) |
| `t` | Next color theme (12 in total) |
| `d` | Next difficulty: `EASY`, `NORMAL`, `HARD`. It applies at once, to the enemies only; the pilot's skill never changes |

| Option | |
| --- | --- |
| `--theme NAME` | `NEON` `PHOSPHOR` `AMBER` `SYNTHWAVE` `GLACIER` `BLOODMOON` `VAPOR` `MONO` `TOXIC` `GILDED` `ABYSS` `PAPER` |
| `--difficulty NAME` | `easy`, `normal` (default) or `hard` |
| `--seed N` | Same seed, same games, **same lines** (as long as you press no keys) |
| `--tick-rate N` | Game steps per second, 10 to 60 (default 30). The game itself is counted in steps, so the same seed plays the same game at any speed |
| `--title-pause SEC` / `--game-over-pause SEC` | How long the title and game over screens stay up (default 5 s and 4 s) |
| `--version` | Print the version and exit |

The terminal needs at least **80×24**. At **100×26 or larger** the HUD gets wider, shows the high-score table, and the last two lines of COMMS run under the field
(Windows Terminal's default 120×30 is enough). If the window is too small, it tells you, in one line, how big it needs to be.

A NORMAL game lasts **a little over three minutes** on average; the careful pilots last about four, the reckless ones about two and a half.

### What happens on screen

- **The swarm** marches side to side and drops a row at each edge, faster as it thins out. Some break off, loop out and dive at you, firing, then come back from the top
- **Flagships** take two hits. Some dive to fire a **capture beam** that grows down from them. A captured ship joins the swarm next to its captor.
  Shoot that flagship **while it is flying** and your ship comes back as a **twin wing**: two ships side by side, two shots at a time
- **Four shields** chip away one cell at a time, from your shots, their shots, and the swarm itself. They come back each stage
- **A saucer** crosses the top now and then, worth a hidden 300 to 1500. Every third stage is a **bonus stage**: twenty quiet flyers, 10,000 for a perfect
- **Effects**: a drifting starfield, bursting explosions, floating scores, a flash on big kills, and big-letter banners (`STAGE 3`, `STAGE CLEAR`, `PERFECT!`, `TWIN WING!`)
- **High scores**: the top five (score, pilot, stage, difficulty) on the title screen and in the HUD, kept in `$XDG_STATE_HOME/nene-swarm/` (or `~/.local/state/nene-swarm/`).
  If the file can't be read or written, it carries on in memory and says so on the title screen

## The pilots

At the title screen one of four is drawn at random for the next game. They dodge and aim differently, and they are rude differently.

| | How they fly | In their words |
| --- | --- | --- |
| **BLASTER.BIN** `(>_<)` | Shoots at everything, looks only a little ahead, and flies into the capture beam on purpose to win a twin wing | *"Statistically, if you shoot everything, you hit something."* |
| **NERVOUS.TMP** `(;_;)` | A temp file afraid of deletion. Looks far ahead, hides under the shields, fires sparingly | *"I'm going to hide under that shield until the sun dies."* |
| **LUCKY.INI** `(^o^)` | A gambler. Hesitates the most, chases the saucer, sometimes takes the beam | *"Twenty-two to one. I like those odds. I like all odds."* |
| **SNIPER.ISO** `(-_-)` | Leads its targets, fires only when lined up, avoids the beam. Says little | *"Precision is a form of mercy. Quicker."* |

Each has 50 lines for twelve moments: the title screen, a stage starting and ending, a kill streak, a big score, a near miss, getting hit, the last ship,
being captured, being rescued, game over and a new record. A few:

> **NERVOUS.TMP** (getting hit) *"Tell my cache I loved it."*<br>
> **LUCKY.INI** (game over) *"Lucky=false. Who edited my config?"*<br>
> **SNIPER.ISO** (game over) *"Unmounted."*<br>
> **BLASTER.BIN** (getting hit) *"Note to self: things also come from the front."*

The other 196 are yours to collect.

## Twelve themes

Cycle with `t`: `NEON` (default), `PHOSPHOR`, `AMBER`, `SYNTHWAVE`, `GLACIER`, `BLOODMOON`, `VAPOR`, `MONO`, `TOXIC`, `GILDED`, `ABYSS`, and `PAPER` (the only light theme).
In every theme the ship, each kind of enemy, both kinds of shots, the shields, the saucer and the explosions are at least 3:1 against the background,
the ship never shares a color with an enemy, and every letter and digit on screen is at least 4.5:1. A test computes this from the cells it actually renders.

---

## Under the hood

NeNe Swarm wears the face of an arcade screensaver, but it is also **an experiment in having machines enforce the rules**.
Every number below is in the repository's records (ADRs, tests, gate proofs).

### 1. The game never reads the clock

The game is one pure function: state plus the pilot's input plus a seeded random source gives the next state, one step at a time.
The game and the pilots **cannot read** the time, random numbers or environment variables; if they try, a home-grown conformance check fails the build.
Only the program's entry point reads the clock and turns seconds into steps. Positions are integers (one cell is 16 units), because `Double.squareRoot()`
does not even link without importing libm, measured before any product code was written ([ADR 0005](docs/adr/0005-fixed-point-field-and-tick-step.md)).

### 2. No published numbers, so 744 games instead

Chess has perft and Go has Tromp's counts; a shooter has nothing to check against. So every `make check` plays **600 games to the end** with two test pilots
and checks every step: the same seed replays the same game, nothing leaves the field, the score only grows by the points of what was destroyed,
ships are only lost by being hit, captures and rescues keep the ship count, every game ends, and harder difficulties end games sooner on average.
Then it plays **144 more with the real pilots**. Shots move in pieces smaller than anything they can hit, so even a shot three cells a step can't jump over an enemy
([ADR 0006](docs/adr/0006-invariant-tests-and-measured-game-length.md)).

### 3. A captive nobody could shoot

The first version put a captured ship directly above its flagship. A test of "shooting your own captive" could not pass: from below, every shot hits the flagship first.
The rule was in the requirements; the geometry made it impossible. The captive now sits half a ship to the side.

### 4. Pilots that look ahead with the game itself

A pilot tries left, right and staying put, runs **the game's own step function** a few dozen steps ahead for each, and picks a safe one that gets closer to its target.
In that look-ahead the random source always rolls "nothing happens", so no new shots or dives appear: it dodges what it can see.
Measuring the first version found NORMAL games lasting one minute, and why: the capture beam reached the bottom the moment it appeared, and divers chased the ship
all the way down at the ship's own speed. Both were unfair, not hard. With the beam now growing and divers committing to their line, NORMAL lands at about 3 minutes 20 seconds
([ADR 0008](docs/adr/0008-pilots-cast-and-game-length.md)).

### 5. Rules aren't written down, they're enforced

The repository has 72 rules, each with an ID and a status saying whether a machine enforces it.
Right now **51 are active** (break one and `make check` fails). The rest are honestly labeled "not yet checked by a machine" or "cannot be blocked by a machine" ([quality gates](docs/QUALITY_GATES.md)).
Swift 6.4.1 was measured in 82 cases before any product code was written ([phase0-results.json](docs/quality/phase0-results.json)), and no check is trusted until it has been seen to fail:
**64 planted violations**, each caught by the intended rule, are recorded in the [gate proofs](docs/quality/gate-proofs.md).
Even the name of the game it pays homage to is a planted violation: write it anywhere in the repository and the build fails.

### 6. The terminal always comes back

Whether it ends with `q`, Ctrl+C or SIGTERM, **or even crashes with SIGSEGV**, it restores the terminal before it dies.
The real binary is run inside a pseudo-terminal on every `make check`.

---

## Development

```bash
make bootstrap           # once after cloning (commit hook and a static SwiftLint binary)
make check               # the one definition of done, identical locally and on CI
make release TAG=v<ver>  # build the release artifacts (only if they pass the checks)
```

- Swift 6.4.1 (`.swift-version`), SwiftPM only, zero external dependencies in the product. About 4,600 lines of source and 1,600 lines of tests
- Entry points: [CLAUDE.md](CLAUDE.md) (Japanese) and [AGENTS.md](AGENTS.md) (English). Design decisions are in 12 [ADRs](docs/adr/README.md); requirements and the owner's decisions are in [REQUIREMENTS.md](docs/REQUIREMENTS.md) (both in Japanese)
- Humans and AI write under the same rules and the same gates. The code here was written by Claude Code; the project owner set the requirements and the decisions

## License

MIT ([LICENSE](LICENSE))
