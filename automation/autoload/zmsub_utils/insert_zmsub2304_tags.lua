re = require 'aegisub.re'
require 'zmsub_utils.general'
versions.insert_zmsub2304_tags = '0.1.1'

local exp_zmsub2304_tag = re.compile('^\\{(?:\\\\blur3\\\\yshad2.5\\\\xshad1.5)?(.+?)\\}')

-- 每行开头插入 \\blur3\\yshad2.5\\xshad1.5
function insert_zmsub2304_tags(line)
    if exp_zmsub2304_tag:match(line.text) then
        -- 开头已有特效代码
        local repl = '{\\\\blur3\\\\yshad2.5\\\\xshad1.5$1}'
        line.text, _ = exp_zmsub2304_tag:sub(line.text, repl)
    else
        -- 开头无特效代码
        local tag = '\\blur3\\yshad2.5\\xshad1.5'
        line.text = '{' .. tag .. '}' .. line.text
    end

    return true
end