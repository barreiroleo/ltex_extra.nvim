---
name: Bug report
about: Create a report to help us improve
title: ''
labels: ''
assignees: ''

---
**Clean your sensitive data from the logs before write the issue**
Please, increase your verbosity log messages before report a bug. More traceability is a help por determinate what is going on.
```lua
  require("ltex_extra").setup{
    log_level = "trace", -- string : "none", "trace", "debug", "info", "warn", "error", "fatal"
  }
```


**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Your settings for ltex are: ...
2. The contex is '....'
3. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**System:**
 - OS: [e.g. Linux, macOS, Windows]
 - Neovim version: [0.6, 0.8, stable, nightly]
 - LTeX server intallation method: [nvim-lsp-installer, mason, manual]

**Additional context**
Add any other context about the problem here.
