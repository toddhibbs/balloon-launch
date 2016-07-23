
--

capmode=require("capmode")


function start_video()
  dbg("START VIDEO")
  sleep(2000)
  status=capmode.set('VIDEO_STD')
  sleep(2000)
  press("shoot_full")
  sleep(1000)
  release("shoot_full")
end


function stop_video()
  dbg("STOP VIDEO")
  sleep(5000)
  press("shoot_full")
  sleep(1000)
  release("shoot_full")
  sleep(5000)  
  while get_prop(115)==1 do
   sleep(500)
  end

  status=capmode.set('AUTO')
  sleep(2000)
end
