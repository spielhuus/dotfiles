local dap = require('dap')
    dap.configurations.python = {
    {
        type = 'python';
        request = 'launch';
        name = "Launch file";
        program = "${file}";
        pythonPath = function()
        return 'python'
        end;
    },
}
require('dap.ui.widgets').hover()
require("dapui").setup()
