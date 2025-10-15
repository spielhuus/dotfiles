return {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".git" },
        single_file_support = true,
        -- settings = {
        --         ["rust-analyzer"] = {
        --                 cargo = {
        --                         allTargets = true,
        --                         allFeatures = true,
        --                 },
        --                 check = {
        --                         command = "clippy",
        --                 },
        --                 procMacro = {
        --                         enable = true,
        --                 },
        --                 diagnostics = {
        --                         enable = false,
        --                 },
        --         },
        -- },
}
