-- MAIN PROGRAM

debugmode=false

-- determine if we are on the camera or if we are just debugging on the PC
if (type(shoot)=="function") then
 -- shoot() is defined, we are on a camera
 
 require("metering")
 require("fast_tv")
 require("video")
 require("display")
 require("info")
else
 -- shoot() is undefined, we are on a PC
 require("dummy")
 -- require("metering_dummy")
 -- require("fast_tv_dummy")
 -- require("video_dummy")
 -- require("display_dummy") 
 -- require("info_dummy")
end

require("scheduler")
require("logging")
require("descent")

 
-- MISSION SCHEDULE
-- defines what will happen at specific times in mission

-- time is in "periods", each period lasting "seconds_per_period"

if (debugmode) then
-- accellerated timeline for debugging
  
 seconds_per_period=5
 
 timeline[0]='enter_phase(1)'; -- filmato iniziale
 timeline[24]='enter_phase(2)'; -- vai in modo bassa quota
 
 timeline[120]='enter_phase(4)'; -- filmato 10k
 timeline[132]='enter_phase(2)'; -- torna in bassa quota
 
 timeline[220]='enter_phase(4)'; -- filmato 18k
 timeline[232]='enter_phase(3)'; -- passa in modo alta quota
 
 -- discesa presunta 375
 
 timeline[380]='enter_phase(4)'; -- filmato 28k
 timeline[384]='enter_phase(5)'; -- modo rallentato 

 timeline[500]='enter_phase(4)'; -- filmato finale
 timeline[504]='enter_phase(5)'; -- modo rallentato 
 
else
 -- standard timeline
 seconds_per_period=15
 
 timeline[0]='enter_phase(1)'; -- filmato iniziale
 timeline[24]='enter_phase(2)'; -- vai in modo bassa quota
 
 timeline[120]='enter_phase(4)'; -- filmato 10k
 timeline[132]='enter_phase(2)'; -- torna in bassa quota
 
 timeline[220]='enter_phase(4)'; -- filmato 18k
 timeline[232]='enter_phase(3)'; -- passa in modo alta quota
 
 -- discesa presunta 375
 
 timeline[380]='enter_phase(4)'; -- filmato 28k
 timeline[388]='enter_phase(5)'; -- modo rallentato 

 timeline[500]='enter_phase(4)'; -- filmato finale
 timeline[504]='enter_phase(5)'; -- modo rallentato 
 
end


-- defined phases are:
-- 1 initial video
-- 2 low altitude
-- 3 high altitude
-- 4 high altitude video
-- 5 descent

-- current mission phase (1..n)
mission_phase=0

-- do we need to change phase?
-- if nil, means "Stay in same phase"
-- if <>nil, gives the phase we must change to
change_phase=nil

-- when we enter phase 5, will it be because of USB signal (true)
-- or because of timeout (false)
phase5_by_USB = false

-- if phase5_by_USB, phase 5 will have a certain duration. (expressed in periods)
-- after this duration we will go in video mode (phase 1)
phase5_duration = 100

initial_feed_made = 0


-- change phase to the specified phase
function enter_phase(n)
 writelog("MIS", "Entering phase "..n)
 change_phase=n
end

function start_of_phase()
 mission_phase=change_phase
 change_phase=nil
end

function phase1()
-- 1 initial video
 
 start_of_phase()
 
 start_video()
 repeat
  refresh_mets()
  sleep(1000)
 until change_phase
 stop_video()
 -- display off
 set_display_mode(2)

end

function phase2()
-- 2 low altitude

-- flash off
set_prop(143,2)

 start_of_phase()
 refresh_mets()
 sleep(2000)
 repeat
  
  -- min shutter 1/1000, max iso 100
  fast_tv_shoot(-1, 957, 418, 24)
   
  writelog("MIS", "Phase 2 shoot(fast Tv)")
  t=mets
  repeat
   refresh_mets()
   sleep(1000)
  until (change_phase) or (mets-t>30)
  
 until change_phase


 
end

function phase3()
-- 3 high altitude
 start_of_phase()
-- flash off
set_prop(143,2)
 

-- first time we enter phase 3 ?
if initial_feed_made==0 then
 initial_feed_made=1
 writelog("MIS", "Initial feed to bvtable ")
  -- initial feed to the metering table
  for n = 1, 60 do
   feed_bvtable()
   sleep(500)
  end
  
 -- from now on we will be watching for descent 
 -- being signalled by the computer
 check_descent_start()
 
 
end
 
 

 

 
 repeat
 
    
  
  writelog("MIS", "Phase 3 sequence")
  -- 50 Fast-Tv shots in rapid sequence
  -- get the averaged bv for the sequence
  sequence_bv=weighted_bv(50,80)
  n=1
  repeat
  
   -- fast tv shooting
   -- exposure time 1/1000, max iso 100
   -- high altitude should mean slower movements
   fast_tv_shoot(sequence_bv, 957, 418, 0)

   
   check_descent()
   
   -- added in v. 19
   feed_bvtable()
   refresh_mets()

   n=n+1
   
  until (change_phase) or (n>20) 
  
  --writelog("MIS", "Phase 3 delay") 
  --n=1
  --repeat   
  -- feed_bvtable()
  -- sleep(1000)
  -- refresh_mets()
  -- check_descent()
  -- n=n+1
  --until (change_phase) or (n>10)
  
 until change_phase
 sleep(2000)
end

function phase4()
-- 4 high altitude video

 start_of_phase()
 writelog("MIS", "High altitude video started")
 start_video()
 repeat
  check_descent()
  refresh_mets()
  sleep(1000)
 until change_phase
 stop_video()
 writelog("MIS", "High altitude video finished")
 -- display off
 set_display_mode(2)
 sleep(2000)
end


function phase5()
-- 5 descent
-- flash off
set_prop(143,2)

 start_of_phase()

  -- clear timeline
 clear_timeline()
 
 if (phase5_by_USB) then
  -- it descent was signaled by USB, then we will only shoot 20 minutes of "dark sky mode" photos,
  -- them we will switch to video mode 
  writelog("MIS", "Entering phase 5 by USB at metp " .. metp) 
  video_metp = metp + phase5_duration
  timeline[video_metp]='enter_phase(1)';
  writelog("MIS", "Final video programmed metp " .. video_metp) 
  
 else 
  writelog("MIS", "Entering phase 5 by timeout at metp " .. metp) 
 end
 
 repeat 
 writelog("MIS", "Phase 5 sequence")
 
 -- sequences of 50 shots in Fast-Tv mode 
 
 -- get the averaged bv for the sequence
 sequence_bv=weighted_bv(50,80)
  
 n=1
 repeat
 
   -- min shutter 1/1000, max iso 100
  fast_tv_shoot(-1, 1053, 514, 32)

  -- refresh bv_table (light might change rather fast during descent)
  feed_bvtable()
  
  n=n+1
  sleep(200)
  refresh_mets()
  
  -- extra pause in descent mode
  sleep(4000)
  
 until (change_phase) or (n>30)
 
 until change_phase

 
end

--- main program starts here

-- flash off
set_prop(143,2)

-- display is left on until the end of start video
if (debugmode) then

else
 sleep(30000)
end
 
print_screen(1)

wait_for_light()


shoot()
sleep(1000)
shoot()
sleep(1000)

ts=timestamp()
init_time()
writelog("MIS", "Mission started at "..ts)

while true do

 if change_phase==1 then
  phase1()
 elseif change_phase==2 then
  phase2()
 elseif change_phase==3 then
  phase3()
 elseif change_phase==4 then
  phase4() 
 elseif change_phase==5 then
  phase5() 
 end

end
             
