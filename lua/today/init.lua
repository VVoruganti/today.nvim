local M = {}

local config = {
  local_root = nil,
  template = "jrnl.md"
}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function convert_format_token(format)
  -- Map high-level template token to Lua strftime equivalent.
  if format == "" then
    return ""
  end

  local named_formats = {
    DATE = "%Y-%m-%d",
    TIME = "%H:%M",
    DATETIME = "%Y-%m-%d %H:%M",
  }

  local upper = format:upper()
  if named_formats[upper] then
    return named_formats[upper]
  end

  -- Replace common journaling shorthands with the matching strftime directives.
  local tokens = {
    { "YYYY", "%Y" },
    { "yyyy", "%Y" },
    { "YY", "%y" },
    { "yy", "%y" },
    { "MMMM", "%B" },
    { "mmmm", "%B" },
    { "MMM", "%b" },
    { "mmm", "%b" },
    { "MM", "%m" },
    { "mm", "%m" },
    { "DDDD", "%A" },
    { "dddd", "%A" },
    { "DDD", "%a" },
    { "ddd", "%a" },
    { "DD", "%d" },
    { "dd", "%d" },
    { "HH", "%H" },
    { "hh", "%I" },
    { "H", "%H" },
    { "h", "%I" },
    { "ss", "%S" },
    { "SS", "%S" },
    { "s", "%S" },
    { "A", "%p" },
    { "a", "%p" }
  }

  local i = 1
  local len = #format
  local result = {}

  while i <= len do
    local handled = false
    local char = format:sub(i, i)

    -- Pass through explicit strftime escapes unchanged.
    if char == "%" then
      local next_char = format:sub(i + 1, i + 1)
      if next_char ~= "" then
        table.insert(result, "%" .. next_char)
        i = i + 2
      else
        table.insert(result, "%")
        i = i + 1
      end
      handled = true
    else
      for _, token in ipairs(tokens) do
        local key, replacement = token[1], token[2]
        local token_len = #key
        if token_len > 0 and format:sub(i, i + token_len - 1) == key then
          table.insert(result, replacement)
          i = i + token_len
          handled = true
          break
        end
      end
    end

    if not handled then
      table.insert(result, char)
      i = i + 1
    end
  end

  return table.concat(result)
end

local function expand_template(template_path, target_time)
  -- Read the template into memory; failure falls back to a raw copy.
  local ok, lines = pcall(vim.fn.readfile, template_path)
  if not ok then
    return nil, "Failed to read template: " .. (lines or "")
  end

  local content = table.concat(lines, "\n")
  local processed = content:gsub("{{(%%.-)}}", function(match)
    -- Strip the leading % and replace supported tokens; unknown formats are left intact.
    local clean = trim(match:sub(2))
    if clean == "" then
      return match
    end

    local converted = convert_format_token(clean)
    local ok_date, formatted = pcall(os.date, converted, target_time)

    if ok_date and formatted then
      return formatted
    end

    return match
  end)

  return vim.split(processed, "\n", { plain = true })
end

local function ensure_default_setup()
  if not config.local_root then
    local home = os.getenv("HOME")
    config.local_root = home .. "/.today"

    -- Create default directory if it doesn't exist
    if vim.fn.isdirectory(config.local_root) == 0 then
      vim.fn.mkdir(config.local_root, "p")

      -- Copy default template
      local plugin_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
      local default_template = plugin_dir .. "jrnl.md"
      local target_template = config.local_root .. "/jrnl.md"

      if vim.fn.filereadable(target_template) == 0 then
        vim.fn.system(string.format("cp %s %s", default_template, target_template))
      end
    end
  end
end

local function today(offset)
  ensure_default_setup()
  offset = offset or 0

  -- Get target date
  local current_time = os.time()
  local target_time = os.time({
    year = os.date('%Y', current_time),
    month = os.date('%m', current_time),
    day = os.date('%d', current_time)
  }) - (offset * 24 * 60 * 60)
  local target_date = os.date("%Y-%m-%d", target_time)

  -- Extract year, month, day
  local year, month, day = target_date:match("(%d+)-(%d+)-(%d+)")

  -- Create directory if it doesn't exist
  local dir = string.format("%s/daily/%s/%s", config.local_root, year, month)
  vim.fn.mkdir(dir, "p")
  -- os.execute(string.format("mkdir -p %s", dir))

  -- Create file path
  local file = string.format("%s/%s.md", dir, target_date)

  -- Check if file exists, if not, copy template
  -- local f = io.open(file, "r")
  if vim.fn.filereadable(file) == 0 then
    local template_path = config.local_root .. "/" .. config.template

    -- Expand placeholders before writing; keep the original template if expansion fails.
    local expanded, err = expand_template(template_path, target_time)
    if not expanded then
      vim.notify(err, vim.log.levels.WARN)
      vim.fn.system(string.format("cp %s %s", template_path, file))
    else
      vim.fn.writefile(expanded, file)
    end
    -- os.execute(string.format("cp %s %s", template_path, file))
    -- else
    -- f:close()
  end

  -- Open file in Neovim
  vim.cmd(string.format("edit %s", file))
end

function M.setup(opts)
  -- Merge user options with default config
  config = vim.tbl_deep_extend("force", config, opts or {})

  vim.api.nvim_create_user_command("Today", function(args)
    local count = args.count ~= 0 and args.count or nil
    local offset = count or tonumber(args.args) or 0
    today(offset)
  end, { nargs = "?", count = true })
end

return M

-- function M.setup(opts)
--   vim.api.nvim_create_user_command("MyPluginHello", function()
--     print("Hello from MyPlugin!")
--   end, {})
-- end
--
-- return M
