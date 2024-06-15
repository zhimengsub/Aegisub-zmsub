-- 计算dialogue行序号相对所有subs行的偏移量，用于debug输出
function linenum_offset(subs)
    local offset = 0
    for i = 1, #subs do
        if subs[i].class ~= "dialogue" then
            offset = i
        else
            break
        end
    end
    return offset
end

versions = {}