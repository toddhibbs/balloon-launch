-- minimal logging/debug functions


function timestamp()
 h=get_time("h")
 m=get_time("m")
 s=get_time("s")
 return ( h .. ":" .. m .. ":" .. s)
end

function dbg(msg)
 --print(msg)
end

function writelog(prefix, msg)
 ts=timestamp()
 print('###' .. prefix .. ' ' .. ts .. ' ' .. mets .. ' ' .. msg)
end
