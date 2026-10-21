vim.opt.rtp:prepend(vim.fn.getcwd())
local projects = require("config.go_projects")
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
tmp = vim.uv.fs_realpath(tmp)
local function write(path, contents)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(vim.split(contents, "\n"), path)
end
local function equal(actual, expected)
  assert(vim.deep_equal(actual, expected), vim.inspect({ actual = actual, expected = expected }))
end
local function fixture(root, name, gitfile)
  if gitfile then
    write(root .. "/.git", "gitdir: /unused/git/worktrees/fixture")
  else
    vim.fn.mkdir(root .. "/.git", "p")
  end
  write(root .. "/go.mod", "module " .. name .. "\ngo 1.23")
  write(root .. "/nested/go.mod", "module example.com/nested\ngo 1.23")
  write(root .. "/nested/file.go", "package nested")
  if name == "github.com/DataDog/datadog-agent" then
    write(
      root .. "/.claude-plugins/datadog-agent-gopls/.claude-plugin/plugin.json",
      vim.json.encode({
        lspServers = {
          gopls = { initializationOptions = { ["build.buildFlags"] = { "-tags=kubelet,kubeapiserver" } } },
        },
      })
    )
  end
end

local original_prefix = vim.env.DOGBREW_PREFIX
local rpc_start = vim.lsp.rpc.start
local ok, err = pcall(function()
  vim.env.DOGBREW_PREFIX = tmp .. "/dogbrew"
  local binary = vim.env.DOGBREW_PREFIX .. "/bin/dd-gopls"
  write(binary, "#!/bin/sh\nexit 0")
  assert(vim.uv.fs_chmod(binary, 493))
  local root = tmp .. "/checkout with spaces"
  fixture(root, "github.com/DataDog/datadog-agent")
  assert(vim.uv.fs_symlink(root, tmp .. "/alias", { dir = true }))
  equal(projects.detect(tmp .. "/alias/nested/file.go"), { root = root, name = "datadog-agent" })
  equal(projects.detect(tmp .. "/alias/nested/new.go"), { root = root, name = "datadog-agent" })

  local other = tmp .. "/renamed-worktree"
  fixture(other, "github.com/DataDog/datadog-agent", true)
  equal(projects.detect(other .. "/nested/file.go"), { root = other, name = "datadog-agent" })
  local source = tmp .. "/renamed-source"
  fixture(source, "github.com/DataDog/dd-source", true)
  fixture(tmp .. "/ordinary", "example.com/ordinary")
  equal(projects.prepare(tmp .. "/ordinary/nested/file.go"), nil)
  equal(projects.detect(tmp .. "/no-repo.go"), nil)

  local launches = {}
  vim.lsp.rpc.start = function(cmd, _, options)
    table.insert(launches, { cmd = cmd, options = options })
    return {}
  end
  local config = projects.setup({
    cmd = { "gopls" },
    root_dir = function(_, on_dir)
      on_dir("default root")
    end,
  })
  local function launch(file, expected_root)
    local buffer = vim.fn.bufadd(file)
    local resolved
    config.root_dir(buffer, function(dir)
      resolved = dir
    end)
    equal(resolved, expected_root)
    local client = { root_dir = resolved, settings = { gopls = { staticcheck = true, gofumpt = true } } }
    config.cmd({}, client)
    return client
  end
  local agent = launch(tmp .. "/alias/nested/file.go", root)
  equal(agent.settings.gopls.env, nil)
  equal(agent.settings.gopls.buildFlags, { "-tags=kubelet,kubeapiserver" })
  equal(agent.settings.gopls.staticcheck, false)
  equal(agent.settings.gopls.gofumpt, true)
  equal(launches[1].cmd, { "gopls" })
  equal(launches[1].options.env, nil)
  launch(other .. "/nested/file.go", other)
  equal(launches[2].cmd, { "gopls" })
  equal(launches[2].options.env, nil)
  equal(launches[2].options.cwd, other)
  local dd_source = launch(source .. "/nested/file.go", source)
  equal(dd_source.settings.gopls.env, nil)
  equal(launches[3].cmd, { binary })
  equal(launches[3].options.env, { GOPLS_DISABLE_MODULE_LOADS = "1" })
  local generic = launch(tmp .. "/ordinary/nested/file.go", "default root")
  equal(generic.settings, { gopls = { staticcheck = true, gofumpt = true } })
  equal(launches[4].cmd, { "gopls" })
  equal(launches[4].options.env, nil)
end)
vim.env.DOGBREW_PREFIX = original_prefix
vim.lsp.rpc.start = rpc_start
vim.fn.delete(tmp, "rf")
if not ok then
  error(err)
end
print("Go project tests passed")
