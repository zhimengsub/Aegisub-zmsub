local tr = aegisub.gettext

script_name = tr"织梦.添加对白特效(2304) (选中行)"
script_description = tr"配合'织梦-对白-2304'样式使用，为选中的'中字\\N日字'格式的对白添加特效，并规范空格、数字宽度。"
script_author = "谢耳朵w"
script_version = "1.0.1"

re = require 'aegisub.re'
require 'zmsub_utils.general'
-- 插入日字特效相关
require 'zmsub_utils.insert_jptag'
-- 添加2304版对白特效相关
require 'zmsub_utils.insert_zmsub2304_tags'
-- 规范空格、数字宽度相关
require 'zmsub_utils.proc_space_digits'


function proc_lines(subs, sels, curr)
    local offset = linenum_offset(subs)
    -- 记录正常和异常的编号，用于显示处理结果
    local normalsels = {}
    local errsels = {}
    for _, i in ipairs(sels) do
		aegisub.progress.set(i * 100 / #sels)
        if subs[i].class == "dialogue" then
            local oline = subs[i]
            local line = subs[i]
            -- 插入日字特效
            if insert_jptag(line) and
            -- 添加2304版对白特效
            insert_zmsub2304_tags(line) and
            -- 规范空格、数字宽度
               proc_space_digits(line) 
            then
                -- 全部成功
                if line.text ~= subs[i].text then
                    subs[i] = line
                    table.insert(normalsels, i)
                end
            else
                -- 有某一个失败
                oline.comment = true
                subs[i] = oline
                table.insert(errsels, i)
                aegisub.debug.out(i-offset .. ": " .. subs[i].text .. "\n")
            end
        end
    end
    aegisub.set_undo_point(script_name)
    
    -- 提示哪些行处理错误，注释并选中这些行
    if #errsels > 0 then
        aegisub.debug.out('\n处理以上对白时发生错误，将被选中并注释！\n请确保对白中存在\\N。\n修复后，选中这些对白然后重新执行本脚本。')
        return errsels
    else
        -- 不存在异常行，则选中所有被处理过的行
        return normalsels
    end
end

aegisub.register_macro(script_name, script_description, proc_lines)
