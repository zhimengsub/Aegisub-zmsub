local tr = aegisub.gettext

script_name = tr("织梦.歌词排序.按时间合并")
script_description = tr("选中按语言聚集排序的双字台词，会把前半部分和后半部分交错在一起")
script_author = "谢耳朵w"
script_version = "0.1"

function sort_by_time(subs, sels, active)
    if #sels % 2 ~= 0 then
        aegisub.debug.out("选中行数应为偶数！")
        return
    end
    first_half_inds = {table.unpack(sels, 1, #sels/2)}
    second_half_inds = {table.unpack(sels, #sels/2+1)}
    -- aegisub.debug.out(string.format("%d", #second_half_inds))
    -- aegisub.debug.out(string.format("%s", subs[second_half_inds[1]].text))
    second_half_lines = {}
    -- store second half lines then remove them from subs
	for i, ind in ipairs(second_half_inds) do
        table.insert(second_half_lines, subs[ind])
    end
    subs.delete(second_half_inds)
    -- add them into first half lines
	for i, ind in ipairs(first_half_inds) do
		aegisub.progress.set(i * 100 / #first_half_inds)
        newind = ind + 1 + i-1
        subs.insert(newind, second_half_lines[i])
	end
	aegisub.set_undo_point(script_name)
    return
end

aegisub.register_macro(script_name, script_description, sort_by_time)
