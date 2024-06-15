local tr = aegisub.gettext

script_name = tr("织梦.歌词排序.按语言拆分")
script_description = tr("选中按时间交错排序的双字台词，会把台词按语言拆为两块")
script_author = "谢耳朵w"
script_version = "0.1"

function table.slice(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
    return sliced
end

function sort_by_lang(subs, sels, active)
    if #sels % 2 ~= 0 then
        aegisub.debug.out("选中行数应为偶数！")
        return
    end
    -- 注意下标从1开始，第一行为奇数行
    -- odd_inds = table.slice(sels, 1, #sels, 2)
    even_inds = table.slice(sels, 2, #sels, 2)
    even_lines = {}
    -- store even lines then remove them from subs
	for i, ind in ipairs(even_inds) do
        table.insert(even_lines, subs[ind])
    end
    subs.delete(even_inds)
    -- append them at last
    for i = 1, #sels/2 do
        aegisub.progress.set(i * 100 / #sels/2)
        newind = sels[#sels/2] + i
        subs.insert(newind, even_lines[i])
    end
	aegisub.set_undo_point(script_name)
    return
end

aegisub.register_macro(script_name, script_description, sort_by_lang)