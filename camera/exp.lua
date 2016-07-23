set_prop(143,2)
print_screen(1)

function timestamp()
 h=get_time("h")
 m=get_time("m")
 s=get_time("s")
 return ( h .. ":" .. m .. ":" .. s)
end
 

print (timestamp(())

 
 --print ("PRIMA "..get_exp_count())
 --shoot()
 --print ("DOPO "..get_exp_count())

 --get_exp_count ritorna il numero della foto appena scattata