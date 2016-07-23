-- Log information that we aren't currently using but that might be useful in future

function log_info()

 t0=get_temperature(0)
 t1=get_temperature(1)
 t2=get_temperature(2)
 orient=get_prop(219)
 volt=get_vbatt() 
 writelog ("INF","Info " .. t0 .." " .. t1 .." " .. t2 .." " .. orient .." " .. volt)
 
end

