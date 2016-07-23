-- FUNCTIONS FOR DESCENT DETECTION
-- 

function check_descent_start()
 -- reset usb so that previous pulses
 -- are no longer valid
 a=get_usb_power()
 dbg("USB reset")
end


function check_descent()
 -- read usb 
 a=get_usb_power()
 dbg("USB value "..a)
 -- if there has been a pulse
 if (a>0) then
  writelog("MIS", "USB sensed!")
  phase5_by_USB = true
  -- go to descent phase
  enter_phase(5)
  
 end
  
end

