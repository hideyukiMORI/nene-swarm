# NeNe Swarm

A terminal screensaver in which a hand-written AI pilot plays a fixed-screen shooter forever: a marching swarm that dives at you,
breakable shields, a capture beam, a bonus saucer, bonus stages and a top-five high score. Title, play, game over, and around again until you press `q`.
Four pilots with their own personalities take turns, and they grumble, joke and gloat in the COMMS panel.
Written in Swift for Ubuntu on WSL2 and Windows Terminal. The game, the collisions and the pilots are written from scratch, with no external engine.
It is a sibling of [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit) (chess), [NeNe Reversi](https://github.com/hideyukiMORI/nene-reversi),
[NeNe Igo](https://github.com/hideyukiMORI/nene-igo) (Go) and [NeNe Poker](https://github.com/hideyukiMORI/nene-poker).

🚧 **Early.** The game runs in an 80×24 terminal: title, play, game over, and around again. Four pilots take turns:
BLASTER.BIN, NERVOUS.TMP, LUCKY.INI and SNIPER.ISO dodge by looking ahead with the game's own step function, aim with lead,
and some fly into the capture beam on purpose to win a dual ship. A NORMAL game lasts a little over three minutes on average.
The swarm marches and dives, shots never tunnel, shields chip, the capture beam and the rescue work, and 600 games played to the end keep
every invariant (determinism, bounds, score and ship counts, every game ending). Each pilot has fifty lines of its own in the COMMS panel. The theme colors and the flashy effects come next.

## Development

```bash
make bootstrap   # once after cloning (commit hook and a static SwiftLint binary)
make check       # the one definition of done, identical locally and on CI
```

- Swift 6.4.1 (`.swift-version`), SwiftPM only, zero external dependencies in the product
- Entry points: [CLAUDE.md](CLAUDE.md) (Japanese) and [AGENTS.md](AGENTS.md) (English). What the machines enforce right now is in [docs/QUALITY_GATES.md](docs/QUALITY_GATES.md); the owner's decisions are in [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md)

## License

MIT ([LICENSE](LICENSE))
