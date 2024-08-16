-- [nfnl] Compiled from fnl/conjure/fs.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local nvim = autoload("conjure.aniseed.nvim")
local a = autoload("conjure.aniseed.core")
local text = autoload("conjure.text")
local str = autoload("conjure.aniseed.string")
local afs = autoload("conjure.aniseed.fs")
local config = autoload("conjure.config")
local function env(k)
  local v = nvim.fn.getenv(k)
  if (a["string?"](v) and not a["empty?"](v)) then
    return v
  else
    return nil
  end
end
local function config_dir()
  return ((env("XDG_CONFIG_HOME") or (env("HOME") .. afs["path-sep"] .. ".config")) .. afs["path-sep"] .. "conjure")
end
local function absolute_path(path)
  return vim.fn.fnamemodify(path, ":p")
end
local function findfile(name, path)
  local res = nvim.fn.findfile(name, path)
  if not a["empty?"](res) then
    return absolute_path(res)
  else
    return nil
  end
end
local function split_path(path)
  local function _4_(_241)
    return not a["empty?"](_241)
  end
  return a.filter(_4_, str.split(path, afs["path-sep"]))
end
local function join_path(parts)
  return str.join(afs["path-sep"], a.concat(parts))
end
local function parent_dir(path)
  local res = join_path(a.butlast(split_path(path)))
  if ("" == res) then
    return nil
  else
    return (afs["path-sep"] .. res)
  end
end
local function upwards_file_search(file_names, from_dir)
  if (from_dir and not a["empty?"](file_names)) then
    local result
    local function _6_(file_name)
      return findfile(file_name, from_dir)
    end
    result = a.some(_6_, file_names)
    if result then
      return result
    else
      return upwards_file_search(file_names, parent_dir(from_dir))
    end
  else
    return nil
  end
end
local function resolve_above(names)
  return (upwards_file_search(names, nvim.fn.expand("%:p:h")) or upwards_file_search(names, nvim.fn.getcwd()) or upwards_file_search(names, config_dir()))
end
local function file_readable_3f(path)
  return (1 == nvim.fn.filereadable(path))
end
local function resolve_relative_to(path, root)
  local function loop(parts)
    if a["empty?"](parts) then
      return path
    else
      if file_readable_3f(join_path(a.concat({root}, parts))) then
        return join_path(parts)
      else
        return loop(a.rest(parts))
      end
    end
  end
  return loop(split_path(path))
end
local function resolve_relative(path)
  local relative_file_root = config["get-in"]({"relative_file_root"})
  if relative_file_root then
    return resolve_relative_to(path, relative_file_root)
  else
    return path
  end
end
local function apply_path_subs(path, path_subs)
  local function _13_(path0, _12_)
    local pat = _12_[1]
    local rep = _12_[2]
    return path0:gsub(pat, rep)
  end
  return a.reduce(_13_, path, a["kv-pairs"](path_subs))
end
local function localise_path(path)
  return resolve_relative(apply_path_subs(path, config["get-in"]({"path_subs"})))
end
local function current_source()
  local info = debug.getinfo(2, "S")
  if text["starts-with"](a.get(info, "source"), "@") then
    return string.sub(info.source, 2)
  else
    return nil
  end
end
local conjure_source_directory
do
  local src = current_source()
  if src then
    conjure_source_directory = vim.fs.normalize((src .. "/../../.."))
  else
    conjure_source_directory = nil
  end
end
local function file_path__3emodule_name(file_path)
  if file_path then
    local function _16_(mod_name)
      local mod_path = string.gsub(mod_name, "%.", afs["path-sep"])
      if (text["ends-with"](file_path, (mod_path .. ".fnl")) or text["ends-with"](file_path, (mod_path .. "/init.fnl"))) then
        return mod_name
      else
        return nil
      end
    end
    return a.some(_16_, a.keys(package.loaded))
  else
    return nil
  end
end
return {env = env, ["config-dir"] = config_dir, ["absolute-path"] = absolute_path, findfile = findfile, ["split-path"] = split_path, ["join-path"] = join_path, ["parent-dir"] = parent_dir, ["upwards-file-search"] = upwards_file_search, ["resolve-above"] = resolve_above, ["file-readable?"] = file_readable_3f, ["resolve-relative-to"] = resolve_relative_to, ["resolve-relative"] = resolve_relative, ["apply-path-subs"] = apply_path_subs, ["localise-path"] = localise_path, ["current-source"] = current_source, ["conjure-source-directory"] = conjure_source_directory, ["file-path->module-name"] = file_path__3emodule_name}
