# About this fork

This repository is a fork of [vorssaint/vorssaint-utils](https://github.com/vorssaint/vorssaint-utils).
It follows upstream for everything and adds the features listed below. The
license (GPL-3.0-or-later) and upstream's attribution are unchanged.

## Additions

### KiwiDesk page in the Dynamic Island

Ported from the KiwiDesk feature of
[Notch Sidekick](https://github.com/Fernando1417/NotchSidekick). It shows one
card per KiwiDesk space that has app
windows, marks the focused space and the frontmost app, and lets you:

- click a card to switch to that space,
- pick a space's layout (bsp, stack, scrolling, monocle, grid, track, floating) from its corner menu,
- click an app icon to bring it forward (clicking again cycles its windows),
- right-click an app icon to make it floating or tiled, or to toggle sticky.

**Turning it on.** Settings → Features → Dynamic Island → KiwiDesk. Like every
feature added after upstream's install list was frozen, it ships uninstalled.
After that the page can be shown, hidden and reordered in the Dynamic Island
settings like any other page. Option-Command-K opens it while the island is open.

**How it reads KiwiDesk.** Through the `kiwidesk` command line tool, found in
`/opt/homebrew/bin`, `/usr/local/bin` or `/usr/bin`, or else on the login
shell's `PATH` (asked once per launch). The tool reaches the KiwiDesk app over
`~/.config/KiwiDesk/KiwiDesk.sock`. No macOS permission is needed. Vorssaint
is not sandboxed, so the socket is reachable.

**Cost.** Nothing runs while the page is closed. While it is open: one
`kiwidesk get_state` when it appears, a `kiwidesk subscribe` stream that
triggers a new read on space, focus, layout and window events, a read when the
frontmost app changes, and a 15-second safety read.

**Code.**

| File | Role |
| --- | --- |
| `Sources/Vorssaint/Services/Notch/KiwiDeskSupport.swift` | Pure logic: decoding `get_state`, ordering spaces, classifying failures, the event stream's line splitting and reconnect back-off. Tested. |
| `Sources/Vorssaint/Services/Notch/KiwiDeskService.swift` | Runs the tool with the shared `BoundedProcessRunner`, keeps the `subscribe` stream, sends actions. |
| `Sources/Vorssaint/UI/Notch/NotchKiwiDeskView.swift` | The island page and its row in the Dynamic Island settings. |
| `Sources/Vorssaint/Core/NotchKiwiDeskStrings.swift` | Text in every app language. |
| `Tests/NotchKiwiDeskTests.swift` | Contracts for the support code and the feature gate. |

Logs go to the unified log under the category `KiwiDesk`.

## Pulling upstream updates

```sh
git remote add upstream https://github.com/vorssaint/vorssaint-utils.git   # once
git fetch upstream
git switch main
git merge upstream/main
```

Fork additions live in their own files wherever possible. Upstream files carry
only the one-line registrations each new feature needs, so a merge conflicts
only when upstream edits the same line. That most often happens when upstream
adds another Dynamic Island page or feature, in these places:

- `AppFeature`'s case list and `FeatureVisibilitySupport`'s list of island features,
- `NotchModule`'s case list,
- `Tests/FeatureCatalogTests.swift` (feature count and the stable id list).

In each case, keep both sides: upstream's new entry and `notchKiwiDesk` / `kiwiDesk`.
