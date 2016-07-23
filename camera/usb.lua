--flash off
set_prop(143,2)


  while true do
   for n = 1,5 do 
    print("doing stuff " ..n)
    sleep(1000)
   end
   print("stuff done")
   a=get_usb_power()
   if (a>0) then
    print("USB DETECTED! ("..a..")")
    shoot()
   else 
    print("USB not detected")
   end 
  end

