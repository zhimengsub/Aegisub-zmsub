re = require 'aegisub.re'
require 'zmsub_utils.general'
versions.insert_jptag = '0.4.6'

local exp_jptag = re.compile('\\\\N{\\\\fnSource Han Sans JP Bold.*?\\}')
local exp_starttag = re.compile('^\\{[^}]*\\}')
local exp_endtag = re.compile('\\{[^}]*\\}$')
-- 增加容错性，防止校对手滑写错符号导致错误
local exp_newline = re.compile('(?:[\\\\/]+N+)+')
local exp_lstrip_nl = re.compile('^(?:[\\\\/]+N*)+')
local exp_rstrip_nl = re.compile('(?:[\\\\/]+N*)+$')

local new_jptag = '\\\\N{\\\\fnSource Han Sans JP Bold\\\\fs55\\\\fsvp10}'

function replace_until_same(text, exp, newtxt)
    local ot = text
    repeat 
        ot = text
        text = exp:sub(text, newtxt)
    until ot == text
    return text
end

-- 把台词中的\\N替换为\\N{\\fnSource Han Sans JP Bold\\fs55\\fsvp10}。换行符匹配[\\/]+N+形式，并删掉头尾的换行符
function insert_jptag(line)
    if exp_jptag:match(line.text) then
        -- 已存在类似日字特效，替换为新版
        line.text = exp_jptag:sub(line.text, new_jptag)
        return true
    else
        -- 不存在特效，在\N后添加特效标签

        -- 去除开头和结尾的特效标签避免影响判断
        local mStarttag = exp_starttag:match(line.text)
        local starttag = ''
        if mStarttag then
            starttag = mStarttag[1]['str']
            line.text, _ = exp_starttag:sub(line.text, '')
        end
        local mEndtag = exp_endtag:match(line.text)
        local endtag = ''
        if mEndtag then
            endtag = mEndtag[1]['str']
            line.text, _ = exp_endtag:sub(line.text, '')
        end

        -- 去除开头和结尾多余的\N
        line.text = replace_until_same(line.text, exp_lstrip_nl, '')
        line.text = replace_until_same(line.text, exp_rstrip_nl, '')

        -- 寻找句中的\N
        local matches = exp_newline:find(line.text)
        if not matches or #matches > 1 then
            -- 错误, 不存在'\N'或存在多个\N
            return false
        else
            -- 只有一个\N，替换为新特效标签
            line.text = exp_newline:sub(line.text, new_jptag)

            -- 添加回开头和结尾的特效标签
            line.text = starttag .. line.text .. endtag
            return true
        end
    end
end