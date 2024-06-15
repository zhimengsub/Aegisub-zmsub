re = require 'aegisub.re'
require 'zmsub_utils.general'
require 'zmsub_utils.insert_zmsub2304_tags'

versions.smart_join_lines = '0.3.1'

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
    local has_unique_tag = false
    local rm = {}
	for _, i in ipairs(sels) do
        if subs[i].class == "dialogue" then
            local res = exp_sep:match(subs[i].text)
            if not res or #res ~= 4 then
                aegisub.debug.out('格式错误：')
                aegisub.debug.out(i-offset .. ": " .. subs[i].text .. "\n")
                return {i}
            else
                local tleft = res[2]['str']
                if exp_unique_tag:match(tleft) then
                    has_unique_tag = true
                    tleft, _ = exp_unique_tag:sub(tleft, '')
                    tleft, _ = re.sub(tleft, '\\{\\}', '')
                end
                table.insert(left, tleft)
                mid = res[3]['str']
                table.insert(right, res[4]['str'])
                table.insert(rm, i)
            end
        end
    end
    left = table.concat(left, sep)
    right = table.concat(right, sep)
    local first = table.remove(rm, 1)
    local edtime = subs[rm[#rm]].end_time
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
