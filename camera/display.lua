-- TURN OFF DISPLAY

function set_display_mode(mode)
-- sets display mode
-- 0 show icons
-- 1 don't show icons
-- 2 off
-- 3 evf

 if (debugmode==false) then
  while (get_prop(105) ~= mode) do
   click "display"
   sleep(200)
  end
 end
  
end


