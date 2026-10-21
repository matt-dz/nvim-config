local M = {}
local projects = {}
local fallback_tags = {}

local function read(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local contents = file:read("*a")
  file:close()
  return contents
end

function M.detect(path)
  path = vim.uv.fs_realpath(path) or path
  local root = vim.fs.root(path, ".git")
  if not root then
    return nil
  end
  root = vim.uv.fs_realpath(root) or root
  local contents = read(root .. "/go.mod")
  local name = contents and ("\n" .. contents):match('\n%s*module%s+"?([^%s"]+)')
  if name == "github.com/DataDog/datadog-agent" or name == "github.com/DataDog/dd-source" then
    return { root = root, name = name:match("([^/]+)$") }
  end
end

local function agent_flags(root)
  local contents = read(root .. "/.claude-plugins/datadog-agent-gopls/.claude-plugin/plugin.json")
  if contents then
    local plugin = vim.json.decode(contents)
    return assert(plugin.lspServers.gopls.initializationOptions["build.buildFlags"], "Missing Agent build flags")
  end
  -- Older branches predate the checked-in LSP settings.
  local source = (read(root .. "/tasks/build_tags.py") or "") .. (read(root .. "/tasks/build_tags.bzl") or "")
  local cached = fallback_tags[root]
  if cached and cached.source == source then
    return cached.flags
  end
  local result = vim
    .system({
      "dda",
      "inv",
      "print-default-build-tags",
      "--build=agent",
      "--platform=linux",
    }, { cwd = root, text = true })
    :wait(30000)
  assert(result.code == 0, "Could not read Agent build tags: " .. (result.stderr or ""))
  local tags = vim.trim(result.stdout):match("([^\n]+)$")
  assert(tags and tags:match("^[%w_.,%-]+$"), "Unexpected Agent build-tag output")
  local flags = { "-tags=" .. tags, "-buildvcs=false" }
  fallback_tags[root] = { source = source, flags = flags }
  return flags
end

function M.prepare(path)
  local project = M.detect(path)
  if not project then
    return nil
  end
  projects[project.root] = nil
  project.settings = {
    staticcheck = false,
    diagnosticsTrigger = "Save",
    ["local"] = "github.com/DataDog/" .. project.name,
  }
  if project.name == "datadog-agent" then
    project.settings.buildFlags = agent_flags(project.root)
  else
    local dogbrew = (vim.env.DOGBREW_PREFIX or "/opt/dogbrew") .. "/bin/dd-gopls"
    project.cmd = vim.fn.executable(dogbrew) == 1 and dogbrew or vim.fn.exepath("dd-gopls")
    assert(project.cmd ~= "", "dd-source requires dd-gopls; install it with dogbrew install dd-gopls")
    project.env = { GOPLS_DISABLE_MODULE_LOADS = "1" }
    project.settings.buildFlags = { "-buildvcs=false" }
    project.settings.directoryFilters = {
      "-**/node_modules",
      "-**/bazel-bin",
      "-**/bazel-out",
      "-**/bazel-testlogs",
      "-**/bazel-dd-source",
    }
  end
  projects[project.root] = project
  return project
end

function M.setup(config)
  local default_root = config.root_dir
  local default_cmd = config.cmd
  config.root_dir = function(bufnr, on_dir)
    local ok, project = pcall(M.prepare, vim.api.nvim_buf_get_name(bufnr))
    if not ok then
      vim.notify("Go project setup failed: " .. tostring(project), vim.log.levels.ERROR)
    elseif project then
      on_dir(project.root)
      return
    end
    default_root(bufnr, on_dir)
  end
  config.cmd = function(dispatchers, client_config)
    local project = projects[client_config.root_dir]
    local cmd = default_cmd
    local env = client_config.cmd_env
    if project then
      client_config.settings.gopls = vim.tbl_deep_extend("force", client_config.settings.gopls, project.settings)
      cmd = project.cmd and { project.cmd } or cmd
      if project.env then
        env = vim.tbl_extend("force", env or {}, project.env)
      end
    end
    return vim.lsp.rpc.start(cmd, dispatchers, { cwd = client_config.root_dir, env = env })
  end
  return config
end

return M
