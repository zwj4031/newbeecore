---
function string.splitlines(str)
  local arr = {}
 for line in string.gmatch(str, "([^\n]+)") do
    table.insert(arr, line)
  end
  return arr
end

---
win = {}

function win.popen(cmd)
  local exitcode, stdout = winapi.execute(cmd)
  stdout = stdout:gsub("\r\n", "\n")
  return stdout
end

---
dir = {}
function dir.folders(path)
  local folders = win.popen('dir /b /ad \"' .. path .. '\"')
  return string.splitlines(folders)
end

---


function msg(msg)
  winapi.show_message('', msg)
end


---
function suilib.genItemXML(template, items, item_regex)
  local xml = {}
  local tmpl = ''
  for i, item in ipairs(items) do
    if item_regex then
      item = item:match(item_regex)
    end
    tmpl = template:gsub('{$I}', i)
    tmpl = tmpl:gsub('{$ITEM}', item)
    table.insert(xml, tmpl)
  end
  return table.concat(xml, "\r\n")
end

function suilib.insertItem(sui_obj, xml, parent_head, parent_foot)
  local str = {}

  if parent_head == nil then parent_head = '<VerticalLayout>' end
  if parent_foot == nil then parent_foot = '</VerticalLayout>' end

  table.insert(str, '<elem>')
  table.insert(str, parent_head)
  table.insert(str, xml)
  table.insert(str, parent_foot)
  table.insert(str, '</elem>')
  sui_obj:add(table.concat(str, "\r\n"))
end
