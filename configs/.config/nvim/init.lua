-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Function to source all files with a specific extension in a directory
local function source_files(directory, extension)
    -- Get the list of files in the directory matching the extension
    local files = vim.fn.glob(directory .. '/*.' .. extension, false, true)
    -- Iterate through each file and source it
    for _, file in ipairs(files) do
        
        if extension == 'vim' then
            -- Source Vim script files using vim.cmd
            vim.cmd('source ' .. file)
        elseif extension == 'lua' then
            -- Source Lua files using dofile
            dofile(file)
        end
    end
end

-- Source all .vim files in the plugin directory
source_files(vim.fn.stdpath("config") .. '/plugin', 'vim')

-- Source all .vim files in the custom-plugins directory
source_files(vim.fn.stdpath("config") .. '/custom-plugins', 'vim')

-- Source all .lua files in the custom-plugins directory
source_files(vim.fn.stdpath("config") .. '/custom-plugins', 'lua')
