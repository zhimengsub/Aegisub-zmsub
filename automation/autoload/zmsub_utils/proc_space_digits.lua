include("unicode.lua")
require 'zmsub_utils.general'
re = require 'aegisub.re'

versions.proc_space_digits = '0.5.0'

local exp_sep = re.compile("(.*)(\\\\N(?:\\{\\\\fnSource Han Sans JP Bold.*?\\})?)(.*)")
local exp_sp = re.compile("[　 ]+")

local exp_digit = re.compile("\\d")
local exp_anytag = re.compile("(\\{[^{}]*\\})")
local exp_lstrip_sp = re.compile("^(\\{[^{}]*\\})* +")
local exp_rstrip_sp = re.compile(" +(\\{[^{}]*\\})*$")

local to_fullwidth = {['1'] = '１', ['2'] = '２', ['3'] = '３', ['4'] = '４', ['5'] = '５',
                      ['6'] = '６', ['7'] = '７', ['8'] = '８', ['9'] = '９', ['0'] = '０'}
local to_halfwidth = {['１'] = '1', ['２'] = '2', ['３'] = '3', ['４'] = '4', ['５'] = '5',
                      ['６'] = '6', ['７'] = '7', ['８'] = '8', ['９'] = '9', ['０'] = '0'}

-- 去除开头结尾的多余空格；任意个全角/半角空格换为一个半角空格
function process_space(text)
    text = exp_sp:sub(text, ' ')
    text = exp_lstrip_sp:sub(text, '$1')
    text = exp_rstrip_sp:sub(text, '$1')
    return text
end

-- 处理对白中的数字，只有一个数字则全角，出现两个以上数字全部半角
function process_partial_digits(text)
    local in_tags = false  -- 避免处理特效标签内的内容
    local res_hw = ""
    local res_fw = ""
    local cnt = 0
    for c in unicode.chars(text) do
        if c == "{" then
            in_tags = true
        end
        if in_tags or not exp_digit:find(c) then
            res_hw = res_hw .. c
            res_fw = res_fw .. c
        else
            cnt = cnt + 1
            res_hw = res_hw .. (to_halfwidth[c] and to_halfwidth[c] or c)
            res_fw = res_fw .. (to_fullwidth[c] and to_fullwidth[c] or c)
        end
        if c == "}" then
            in_tags = false
        end
    end
    if cnt >= 2 then
        -- 两位以上数字全部半角
        return res_hw
    end
    -- 只有一位数字则全角
    return res_fw
end

-- 处理对白中的数字、空格，中文和日文分开处理
function process_text(text, is_bilingual)
    if is_bilingual then
        local res = exp_sep:match(text)
        if not res or #res ~= 4 then
            return ''
        end
        -- 中文部分
        local zhs = res[2]['str']
        -- 换行符+特效
        local sep = res[3]['str']
        -- 日文部分
        local jps = res[4]['str']

        zhs = process_space(zhs)
        zhs = process_partial_digits(zhs)
        jps = process_space(jps)
        jps = process_partial_digits(jps)
        return zhs..sep..jps
    else
        text = process_space(text)
        text = process_partial_digits(text)
        return text
    end
end


function proc_space_digits(line)
    -- 对白是否包含单个换行符、可能有jptag日字特效标签
    local matches = exp_sep:find(line.text)
    -- 如果无换行符，则不区分中日部分，对整行进行处理
    local is_bilingual = true

    if not matches then
        is_bilingual = false
    elseif #matches>1 then
        -- 格式错误
        return false
    end

    local nt = process_text(line.text, is_bilingual)
    -- pcall == try catch
    -- succ, nt = pcall(process_digits, nt)
    if nt == '' then
        return false
    elseif nt ~= line.text then
        line.text = nt
    end
    return true
end