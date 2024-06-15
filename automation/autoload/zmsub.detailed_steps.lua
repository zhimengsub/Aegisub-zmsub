local tr = aegisub.gettext
script_name = tr("织梦.对白处理.拆解步骤")
script_description = tr("允许你分开运行'织梦.对白处理'里的特定步骤")
script_author = "谢耳朵w"
script_version = "0.1"

re = require 'aegisub.re'
require 'zmsub_utils.general'

-- 插入日字特效相关
require 'zmsub_utils.insert_jptag'
-- 添加2304版对白特效相关
require 'zmsub_utils.insert_zmsub2304_tags'
-- 规范空格、数字宽度相关
require 'zmsub_utils.proc_space_digits'

switches = {
    insert_jptag = false,
    insert_zmsub2304_tags = false,
    proc_space_digits = false,
}

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
            local ret = true

            if switches.insert_jptag then
                -- 插入日字特效
                ret = insert_jptag(line) 
            elseif switches.proc_space_digits then
                -- 规范空格、数字宽度
                ret = proc_space_digits(line) 
            elseif switches.insert_zmsub2304_tags then
                -- 添加2304版对白特效
                ret = insert_zmsub2304_tags(line)
            else
                aegisub.debug.out('没有选中任何选项！')
                return sels
            end
            if ret then
                -- 成功
                subs[i] = line
                table.insert(normalsels, i)
            else
                -- 失败
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
        aegisub.debug.out('\n处理以上对白时发生错误，将被选中并注释！\n请修复后，选中这些对白然后重新执行本脚本。')
        return errsels
    else
        -- 不存在异常行，则选中所有被处理过的行
        return normalsels
    end
end

TLL_macros = {
	{
		script_name = "1.插入日字特效",
		script_description = "为选中的'中字\\N日字'格式插入'{\\fnSource Han Sans JP Bold\\fs55\\fsvp10}'，并删掉头尾的换行符",
		entry = function(subs,sel) switches.insert_jptag=true proc_lines(subs, sel) end,
		validation = false,
        version = versions.insert_jptag,
	},
	{
        script_name = "2.插入模糊阴影(2304)",
		script_description = "每行开头插入'\\blur3\\yshad2.5\\xshad1.5'特效",
		entry = function(subs,sel) switches.insert_zmsub2304_tags=true proc_lines(subs, sel) end,
		validation = false,
        version = versions.insert_zmsub2304_tags,
	},
    {
        script_name = "3.规范空格、数字宽度",
        script_description = "连续的全/半角空格全部替换为一个半角空格；对白只有一位数字则全角，两位以上数字全部半角。",
        entry = function(subs,sel) switches.proc_space_digits=true proc_lines(subs, sel) end,
        validation = false,
        version = versions.proc_space_digits,
    },
}

for i = 1, #TLL_macros do
	aegisub.register_macro(script_name.."/"..TLL_macros[i].script_name.."v"..TLL_macros[i].version, TLL_macros[i].script_description, TLL_macros[i].entry, TLL_macros[i].validation)
end
