local tr = aegisub.gettext

script_name = tr"织梦.检查中日符号一致性 (所有行)"
script_description = tr"检查中字和日字部分的符号是否一致。目前检查的符号有…，。？！,.!、「」『』【】"
script_author = "谢耳朵w"
script_version = "0.2"

re = require 'aegisub.re'
require 'zmsub_utils.general'
local exp_sep = re.compile("(.*)(\\\\N(?:\\{\\\\fnSource Han Sans JP Bold.*?\\})?)(.*)")
local exp_lstrip_nl = re.compile('^(?:[\\\\/]+N*)+')
local exp_rstrip_nl = re.compile('(?:[\\\\/]+N*)+$')

function replace_until_same(text, exp, newtxt)
    local ot = text
    repeat 
        ot = text
        text = exp:sub(text, newtxt)
    until ot == text
    return text
end

local exp_SYMBOLS_CHECK = re.compile("[…，。？！,.!、「」『』【】]")
function check_symbol_consistency(tleft, tright)
    local symbols_found = {}
    local symbol = ''
    for symbol, start_idx, end_idx in exp_SYMBOLS_CHECK:gfind(tleft) do
        -- aegisub.debug.out('symbol lefft: ' .. symbol .. '\n')
        table.insert(symbols_found, symbol)
    end
    
    local index = 1
    for symbol, start_idx, end_idx in exp_SYMBOLS_CHECK:gfind(tright) do
        -- aegisub.debug.out('symbol right: ' .. symbol .. '\n')
        if symbols_found[index] ~= symbol then
            return false
        end
        index = index + 1
    end
    return true
end

function proc_lines(subs, sels, curr)
    local offset = linenum_offset(subs)
    -- 记录正常和异常的编号，用于显示处理结果
    local normalsels = {}
    local errsels = {}
    local skipsels = {}
    for i = 1, #subs do
		aegisub.progress.set(i * 100 / #subs)
        if subs[i].class == "dialogue" then
            local oline = subs[i]
            local line = subs[i]
            
            -- 删除特效标签
            line.text = line.text:gsub("{[^}]+}", "")

            -- 去除开头和结尾多余的\N
            line.text = replace_until_same(line.text, exp_lstrip_nl, '')
            line.text = replace_until_same(line.text, exp_rstrip_nl, '')

            -- 拆分中日字
            local res = exp_sep:match(line.text)
            if not res or #res ~= 4 then
                -- 格式不规范，如果没有注释就记录下来
                if not line.comment then
                    table.insert(skipsels, i)
                end
            else
                local tleft = res[2]['str']
                local tright = res[4]['str']
                
                -- 检查中日字符号是否一致
                if not check_symbol_consistency(tleft, tright) then
                    -- 不一致则注释并选中
                    oline.comment = true
                    subs[i] = oline
                    table.insert(errsels, i)
                else
                    table.insert(normalsels, i)
                end

            end
        end
    end
    aegisub.set_undo_point(script_name)
    
    if #skipsels > 0 then
        for _, i in ipairs(skipsels) do
            aegisub.debug.out(i-offset .. ": " .. subs[i].text .. "\n")
        end
        aegisub.debug.out('\n以上行格式错误，跳过检查\n=============================\n')
    end

    -- 提示哪些行处理错误，注释并选中这些行
    if #errsels > 0 then
        for _, i in ipairs(errsels) do
            aegisub.debug.out(i-offset .. ": " .. subs[i].text .. "\n")
        end
        aegisub.debug.out('\n以上对白的符号不一致，将被选中并注释！')
        return errsels
    else
        -- 不存在异常行，则选中所有被处理过的行
        aegisub.debug.out('全部检查通过！')
        return normalsels
    end
end

aegisub.register_macro(script_name, script_description, proc_lines)
