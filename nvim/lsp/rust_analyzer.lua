return {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", ".git" },
        single_file_support = true,
        settings = {
                ["rust-analyzer"] = {
                        cargo = {
                                allTargets = true,
                                allFeatures = true,
                        },
                        check = {
                                command = "clippy",
                        },
                        procMacro = {
                                enable = true,
                        },
                        diagnostics = {
                                enable = false,
                        },
                },
        },
}
