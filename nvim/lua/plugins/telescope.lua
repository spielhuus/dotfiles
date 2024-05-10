return {
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    enabled = true,
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'tsakirist/telescope-lazy.nvim',
      'cljoly/telescope-repo.nvim',
      'lpoto/telescope-docker.nvim',
      'nvim-telescope/telescope-symbols.nvim',

      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
        extensions = {
          lazy = {
            -- Optional theme (the extension doesn't set a default theme)
            theme = "ivy",
            -- Whether or not to show the icon in the first column
            show_icon = true,
            -- Mappings for the actions
            mappings = {
              open_in_browser = "<C-o>",
              open_in_file_browser = "<M-b>",
              open_in_find_files = "<C-f>",
              open_in_live_grep = "<C-g>",
              open_in_terminal = "<C-t>",
              open_plugins_picker = "<C-b>", -- Works only after having called first another action
              open_lazy_root_find_files = "<C-r>f",
              open_lazy_root_live_grep = "<C-r>g",
              change_cwd_to_plugin = "<C-c>d",
            },
            -- Configuration that will be passed to the window that hosts the terminal
            -- For more configuration options check 'nvim_open_win()'
            terminal_opts = {
              relative = "editor",
              style = "minimal",
              border = "rounded",
              title = "Telescope lazy",
              title_pos = "center",
              width = 0.5,
              height = 0.5,
            },
            -- Other telescope configuration options
          },
          docker = {
            -- These are the default values
            theme = "ivy",
            binary = "docker", -- in case you want to use podman or something
            compose_binary = "docker compose",
            buildx_binary = "docker buildx",
            machine_binary = "docker-machine",
            log_level = vim.log.levels.INFO,
            init_term = "tabnew", -- "vsplit new", "split new", ...
            -- NOTE: init_term may also be a function that receives
            -- a command, a table of env. variables and cwd as input.
            -- This is intended only for advanced use, in case you want
            -- to send the env. and command to a tmux terminal or floaterm
            -- or something other than a built in terminal.
          },
        }
      }

      -- Enable telescope repo, if installed
      pcall(require('telescope').load_extension, 'docker')

      -- Enable telescope repo, if installed
      pcall(require('telescope').load_extension, 'repo')

      -- Enable telescope lazy, if installed
      pcall(require('telescope').load_extension, 'lazy')

      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')

      -- -- Telescope live_grep in git root
      -- -- Function to find the git root directory based on the current buffer's path
      -- local function find_git_root()
      --   -- Use the current buffer's path as the starting point for the git search
      --   local current_file = vim.api.nvim_buf_get_name(0)
      --   local current_dir
      --   local cwd = vim.fn.getcwd()
      --   -- If the buffer is not associated with a file, return nil
      --   if current_file == '' then
      --     current_dir = cwd
      --   else
      --     -- Extract the directory from the current file's path
      --     current_dir = vim.fn.fnamemodify(current_file, ':h')
      --   end
      --
      --   -- Find the Git root directory from the current file's path
      --   local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
      --   if vim.v.shell_error ~= 0 then
      --     print 'Not a git repository. Searching on current working directory'
      --     return cwd
      --   end
      --   return git_root
      -- end
      --
      -- -- Custom live_grep function to search in git root
      -- local function live_grep_git_root()
      --   local git_root = find_git_root()
      --   if git_root then
      --     require('telescope.builtin').live_grep {
      --       search_dirs = { git_root },
      --     }
      --   end
      -- end
      --
      -- vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
      --
      -- -- See `:help telescope.builtin`
      -- vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
      -- vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
      -- vim.keymap.set('n', '<leader>/', function()
      --   -- You can pass additional configuration to telescope to change theme, layout, etc.
      --   require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      --     winblend = 10,
      --     previewer = false,
      --   })
      -- end, { desc = '[/] Fuzzily search in current buffer' })
      --
      -- local function telescope_live_grep_open_files()
      --   require('telescope.builtin').live_grep {
      --     grep_open_files = true,
      --     prompt_title = 'Live Grep in Open Files',
      --   }
      -- end

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

    end
  },
}
