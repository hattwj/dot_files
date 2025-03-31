---
--- Copy things over ssh between nvim instances. They both need to have this plugin installed.
---

local M = {}

local function is_ssh()
  return vim.env.SSH_TTY ~= nil
end

local function ensure_local_dir()
  local dir = os.getenv("HOME") .. "/.local"
  os.execute("mkdir -p " .. dir)
end

local function get_remote_hosts()
  local handle = io.popen("timeout 5 ps -aux|grep -o ' [s]sh .*'|uniq|cut -d ' ' -f 3")
  local result = handle:read("*a")
  handle:close()

  local hosts = {}
  for host in result:gmatch("[^\r\n]+") do
    table.insert(hosts, host)
  end
  return hosts
end

local function rsync_file(local_path, remote_host, remote_path, direction)
  local cmd
  if direction == "push" then
    cmd = string.format("timeout 9 rsync -ave ssh %s %s:%s", local_path, remote_host, remote_path)
  else
    cmd = string.format("timeout 9 rsync -ave ssh %s:%s %s", remote_host, remote_path, local_path)
  end
  vim.notify("sshCopySwap running command: " .. cmd, nil, {})
  -- runs command on a sub-process.
  local handle = io.popen(cmd)
  if handle ~= nil then
    error("Rsync operation failed or timed out")
    return 1
  end
  -- reads command output.
  local output = handle:read('*a')
  local exit_code = handle:close()
  if exit_code ~= 0 then
    error("Rsync operation failed or timed out")
    error(output)
  end
  return exit_code
end

local function fileToClipboard(local_path, args)
  local file = assert(io.open(local_path, "rb"))
  local data = file:read("*all")
  file:close()
  -- Split the string into lines
  local lines = vim.split(data, "\n")

  -- Load the data into clipboard for later use
  if is_ssh() then
    vim.fn.setreg('"', data)
  else
    vim.fn.setreg('*', data)
    vim.fn.setreg('+', data)
  end
  if args == 'p' then
    vim.api.nvim_paste(data, true, -1)
  end
end

local function pasteToHost(local_path, remote_path, selected_host, args)
  local exit_code = pcall(rsync_file, local_path, selected_host, remote_path, "pull")
  if exit_code == 0 then
    vim.notify("XPaste failed: rsync error", 4, {})
    return
  end
  fileToClipboard(local_path, args)
end

local function copyToHost(local_path, remote_path, selected_host)
  local exit_code = pcall(rsync_file, local_path, selected_host, remote_path, "push")
  if exit_code == 0 then
    vim.notify("XCopy failed: rsync error", 4, {})
    return
  end
end

function M.xcopy()
  ensure_local_dir()
  local clipboard = is_ssh() and vim.fn.getreg('"') or vim.fn.getreg('+')
  local local_path = os.getenv("HOME") .. "/.local/.nvim_xcopy"
  local remote_path = "~/.local/.nvim_xpaste"

  local file = io.open(local_path,"w+")
  file:write(clipboard)
  file:close()

  local line_count = select(2, clipboard:gsub('\n', '\n'))
  if is_ssh() then
    -- Nothing left to do
    vim.notify("XCopy: " .. line_count .. " lines copied to " .. local_path, nil, {})
    return
  end

  local hosts = get_remote_hosts()
  if #hosts == 0 then
    vim.notify("XCopy: No active SSH connections found", 4, {})
    return
  end

  if #hosts == 1 then
    copyToHost(local_path, remote_path, hosts[1])
    vim.notify("XCopy: " .. line_count .. " lines copied to " .. hosts[1] .. ':' .. remote_path, nil, {})
    return
  end

  vim.ui.select(hosts, {prompt="xCopy: select target host"}, function(selected_host)
    if selected_host then
      copyToHost(local_path, remote_path, selected_host)
      vim.notify("XCopy: " .. line_count .. " lines copied to " .. selected_host .. ':' .. remote_path, nil, {})
    end
  end)
end

function M.xpaste(opts)
  ensure_local_dir()
  local local_path = os.getenv("HOME") .. "/.local/.nvim_xpaste"
  local remote_path = "~/.local/.nvim_xcopy"

  if is_ssh() then
    fileToClipboard(local_path, opts.args)
    return
  end

  local hosts = get_remote_hosts()
  if #hosts == 0 then
    vim.notify("XPaste: No active SSH connections found", 4, {})
    return
  end

  if #hosts == 1 then
    pasteToHost(local_path, remote_path, hosts[1], opts.args)
    vim.notify("XPaste: clipboard contents from " .. local_path .. " sent to " .. hosts[1] .. ':' .. remote_path, nil, {})
    return
  end

  vim.ui.select(hosts, {prompt="xPaste: select target host"}, function(selected_host)
    if selected_host then
      pasteToHost(local_path, remote_path, selected_host, opts.args)
      vim.notify("XPaste: clipboard contents from " .. local_path .. " sent to " .. selected_host .. ':' .. remote_path, nil, {})
    end
  end)
end

-- Set up commands
vim.api.nvim_create_user_command('XCopy', M.xcopy, {})
vim.api.nvim_create_user_command('XPaste', M.xpaste, {nargs='?'})

-- Set up key mappings for normal and visual mode
vim.keymap.set({'n'}, '<C-y>', '<cmd>XCopy<CR>', {noremap = true, silent = true})
vim.keymap.set({'n'}, '<C-p>', '<cmd>XPaste p<CR>', {noremap = true, silent = true})

--  In visual mode, yank the current selection, and then copy it to the remote machine
vim.keymap.set({'v'}, '<C-y>', 'y<cmd>XCopy<CR>', {noremap = true, silent = true})
-- In visual mode, delete the current selection, and then copy the data from the remote machine and paste it
vim.keymap.set({'v'}, '<C-p>', 'x<cmd>XPaste p<CR>', {noremap = true, silent = true})

return M
