local keymap = vim.keymap.set

require("snacks").setup((function()
  -- Define Snacks locally to avoid calling require() in every single keymap
  local Snacks = require("snacks")

  -- Top Pickers & Explorer
  keymap("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
  keymap("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers" })
  keymap("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
  keymap("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "Command History" })
  keymap("n", "<leader>n", function() Snacks.picker.notifications() end, { desc = "Notification History" })
  keymap("n", "<leader>e", function() Snacks.explorer() end, { desc = "File Explorer" })

  -- find
  keymap("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
  keymap("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config File" })
  keymap("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
  keymap("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find Git Files" })
  keymap("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })
  keymap("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent" })

  -- git
  keymap("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
  keymap("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
  keymap("n", "<leader>gL", function() Snacks.picker.git_log_line() end, { desc = "Git Log Line" })
  keymap("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })
  keymap("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git Stash" })
  keymap("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
  keymap("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Log File" })

  -- gh
  keymap("n", "<leader>gi", function() Snacks.picker.gh_issue() end, { desc = "GitHub Issues (open)" })
  keymap("n", "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, { desc = "GitHub Issues (all)" })
  keymap("n", "<leader>gp", function() Snacks.picker.gh_pr() end, { desc = "GitHub Pull Requests (open)" })
  keymap("n", "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, { desc = "GitHub Pull Requests (all)" })

  -- Grep
  keymap("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
  keymap("n", "<leader>sB", function() Snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers" })
  keymap("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep" })
  keymap({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "Visual selection or word" })

  -- search
  keymap("n", '<leader>s"', function() Snacks.picker.registers() end, { desc = "Registers" })
  keymap("n", "<leader>s/", function() Snacks.picker.search_history() end, { desc = "Search History" })
  keymap("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "Autocmds" })
  -- Note: <leader>sb was duplicated in your list, removed the duplicate here
  keymap("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "Command History" })
  keymap("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands" })
  keymap("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
  keymap("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
  keymap("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages" })
  keymap("n", "<leader>sH", function() Snacks.picker.highlights() end, { desc = "Highlights" })
  keymap("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons" })
  keymap("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps" })
  keymap("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
  keymap("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location List" })
  keymap("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks" })
  keymap("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages" })
  keymap("n", "<leader>sp", function() Snacks.picker.lazy() end, { desc = "Search for Plugin Spec" })
  keymap("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
  keymap("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume" })
  keymap("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "Undo History" })
  keymap("n", "<leader>uC", function() Snacks.picker.colorschemes() end, { desc = "Colorschemes" })

  -- LSP
  keymap("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
  keymap("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
  keymap("n", "gr", function() Snacks.picker.lsp_references() end, { nowait = true, desc = "References" })
  keymap("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
  keymap("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
  keymap("n", "gai", function() Snacks.picker.lsp_incoming_calls() end, { desc = "C[a]lls Incoming" })
  keymap("n", "gao", function() Snacks.picker.lsp_outgoing_calls() end, { desc = "C[a]lls Outgoing" })
  keymap("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
  keymap("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })

  return {
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = {
      enabled = true,
      layout = { preset = "ivy", layout = { position = "bottom" } }
    },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
    styles = {
      notification = {
        -- wo = { wrap = true }
      },
    },
  }
end)())
