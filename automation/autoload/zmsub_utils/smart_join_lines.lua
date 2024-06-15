re = require 'aegisub.re'
require 'zmsub_utils.general'
require 'zmsub_utils.insert_zmsub2304_tags'

versions.smart_join_lines = '0.3.2'

local exp_sep = re.compile("(.*)(\\\\N(?:\\{\\\\fnSource Han Sans JP Bold.*?\\})?)(.*)")
local exp_unique_tag = re.compile('\\\\blur3\\\\yshad2.5\\\\xshad1.5')

function smart_join_lines(subs, sels, sep)
    if #sels <= 1 then
        return sels
    end
    local offset = linenum_offset(subs)
    local left = {}
    local mid = ''
    local right = {}
    local has_unique_tag = false  -- 是否有模糊阴影特效
    local rm = {}
	for _, i in ipairs(sels) do
        if subs[i].class == "dialogue" then
            local res = exp_sep:match(subs[i].text)
            if not res or #res ~= 4 then
                aegisub.debug.out('格式错误：')
                aegisub.debug.out(i-offset .. ": " .. subs[i].text .. "\n")
                return {i}
            else
                local txt_l = res[2]['str']
                -- 检查是否有模糊阴影特效，如果有，先删掉，最后再加回来
                if exp_unique_tag:match(txt_l) then
                    has_unique_tag = true
                    txt_l, _ = exp_unique_tag:sub(txt_l, '')
                    txt_l, _ = re.sub(txt_l, '\\{\\}', '')
                end
                -- 左右两边的文本分开存储
                table.insert(left, txt_l)
                mid = res[3]['str']
                table.insert(right, res[4]['str'])
                -- 记录发生合并的行号，用于删除
                table.insert(rm, i)
            end
        end
    end
    -- 左边拼左边 右边拼右边 中间的不变
    left = table.concat(left, sep)
    right = table.concat(right, sep)
    local first = table.remove(rm, 1)
    local edtime = subs[rm[#rm]].end_time
    -- 先把原对白删掉 再插入合并后的对白
    subs.delete(rm)
    
    local line = subs[first]
    line.text = left .. mid .. right
    if has_unique_tag then
        insert_zmsub2304_tags(line)
    end

    if edtime > 0 then
        line.end_time = edtime
    end

    subs[first] = line
	aegisub.set_undo_point(script_name)
    return {first}
end
