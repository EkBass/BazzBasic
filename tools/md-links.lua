-- md-links.lua - offline manual only (build-manual.bat).
-- The online manual (docsify) links pages as "page.md", "page.md#id" or
-- "page.md?id=x". In the single-file HTML those must become "#anchor".
--   page.md          -> first heading of that page
--   page.md#x / ?id=x -> #x
--   page.md not in this build -> the online manual page
local ONLINE = "https://ekbass.github.io/BazzBasic/manual/#/"
local first_id = {}

for _, f in ipairs(PANDOC_STATE.input_files) do
  local h = io.open(f, "r")
  if h then
    local doc = pandoc.read(h:read("a"), "markdown")
    h:close()
    local name = f:match("([^/\\]+)%.md$")
    for _, b in ipairs(doc.blocks) do
      if b.t == "Header" then
        first_id[name] = b.identifier
        break
      end
    end
  end
end

function Link(el)
  local t = el.target
  if t:match("^%a+://") then return nil end
  local page, rest = t:match("^%.?/?([%w_%-]+)%.md(.*)$")
  if not page then return nil end
  local anchor = rest:match("^#(.+)$") or rest:match("^%?id=(.+)$")
  if first_id[page] then
    el.target = "#" .. (anchor or first_id[page])
  else
    el.target = ONLINE .. page .. (anchor and ("?id=" .. anchor) or "")
  end
  return el
end
