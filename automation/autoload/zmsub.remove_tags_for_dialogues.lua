local tr = aegisub.gettext

require 'strip-tags'

script_name = tr"织梦.删除对白特效 (选中行)"
script_description = tr"删除选中行的特效代码（花括号部分）。"
script_author = "谢耳朵w"
script_version = "1.0"


function proc_lines(subs, sels)
    strip_tags(subs, sels)
end

aegisub.register_macro(script_name, script_description, proc_lines)
