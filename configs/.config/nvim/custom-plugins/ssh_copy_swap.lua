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
    print("sshCopySwap - Found host: " .. host)
    table.insert(hosts, host)
  end
  return hosts
end

local function select_host(hosts)
  if #hosts == 1 then
    return hosts[1]
  elseif #hosts > 1 then
    local selected = vim.fn.inputlist(vim.list_extend({"Select a remote host:"}, hosts))
    if selected > 0 and selected <= #hosts then
      return hosts[selected]
    end
  end
  return nil
end

local function rsync_file(local_path, remote_host, remote_path, direction)
  local cmd
  if direction == "push" then
    cmd = string.format("timeout 9 rsync -ave ssh %s %s:%s", local_path, remote_host, remote_path)
  else
    cmd = string.format("timeout 9 rsync -ave ssh %s:%s %s", remote_host, remote_path, local_path)
  end
  print('sshCopySwap - Running command: ' .. cmd)
  -- runs command on a sub-process.
  local handle = io.popen(cmd)
  -- reads command output.
  local output = handle:read('*a')
  local exit_code = handle:close()
  if exit_code ~= 0 then
    error("Rsync operation failed or timed out")
    error(output)
  end
  return exit_code
end

function M.xcopy()
  ensure_local_dir()
  local clipboard = is_ssh() and vim.fn.getreg('"') or vim.fn.getreg('*')
  local local_path = os.getenv("HOME") .. "/.local/.nvim_xcopy"
  local remote_path = "~/.local/.nvim_xpaste"

  local file = io.open(local_path,"w+")
  file:write(clipboard)
  file:close()

  if not is_ssh() then
    local hosts = get_remote_hosts()
    if #hosts == 0 then
      print("No active SSH connections found. Aborting XCopy.")
      return
    end
    local selected_host = select_host(hosts)
    if selected_host then
      local exit_code = pcall(rsync_file, local_path, selected_host, remote_path, "push")
      if exit_code == 0 then
        return
      end
    end
  end
end

function M.xpaste()
  ensure_local_dir()
  local local_path = os.getenv("HOME") .. "/.local/.nvim_xpaste"
  local remote_path = "~/.local/.nvim_xcopy"

  if not is_ssh() then
    local hosts = get_remote_hosts()
    if #hosts == 0 then
      print("No active SSH connections found. Aborting XPaste.")
      return
    end
    local selected_host = select_host(hosts)
    if selected_host then
      local exit_code = pcall(rsync_file, local_path, selected_host, remote_path, "pull")
      if exit_code == 0 then
        return
      end
    end
  end

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
  end

  -- Insert the lines at the current cursor position
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)
end

-- Set up commands
vim.api.nvim_create_user_command('XCopy', M.xcopy, {})
vim.api.nvim_create_user_command('XPaste', M.xpaste, {})

-- Set up key mappings for command mode
-- vim.api.nvim_set_keymap('c', '<C-y>', '<cmd>XCopy<CR>', {noremap = true, silent = true})
-- vim.api.nvim_set_keymap('c', '<C-p>', '<cmd>XPaste<CR>', {noremap = true, silent = true})

return M
