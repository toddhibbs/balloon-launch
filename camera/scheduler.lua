-- MISSION TIMER AND SCHEDULER
-- executes lua statements at specific times of "mission"
-- By "mission" we mean the run of the program

-- the functions are contained in the timeline[] array
timeline={}

-- the snippets of lua code specified in timeline[] will be executed at the specified times

-- for exampe:
-- timeline[20]='print(123)';

-- times are in mission periods
-- the duration of each period (in seconds) is:
-- seconds_per_period=15 (SET IN MAIN PROGRAM)

-- this also defines the granularity of the scheduler 
-- (i.e. the minimum time resolution between statements)

-- The scheduler must be initialized by calling time_init()
-- then all we have to do is periodically call refresh_mets()
-- and the snippets in timeline[] will be executed accordingly
-- the accuracy of the scheduling is determined by the delay
-- between subsequent calls to refresh_mets()

-- Start-of-mission time
-- (the get_tick_count() value when the mission started)
somt = -1 

-- Mission elapsed time in periods
-- (how many period are elapsed since somt)
metp = -1

-- Mission elapsed time in seconds
-- (how many seconds are elapsed since somt)
mets = -1

-- value of get_tick_count() when the next period will start (to ease calculations)
period_rollover =-1 

-- clear the timeline
function clear_timeline()
 timeline={}
end 

-- Refreshes the value of mets
-- and checks if we need to go into next period
function refresh_mets() 
 local t
 t=get_tick_count()
 
 -- get met in seconds
 mets = (t-somt)/1000
 
 -- check if we are into next period
 if t>period_rollover then
  refresh_metp()
 end
end

-- ok, we are going into next period
function refresh_metp()
 -- remember a period has passed
 metp=metp+1
 
 -- set somt when next period will pass
 period_rollover=period_rollover + seconds_per_period*1000
 -- the line above ensures that even if we call refresh_mets()
 -- with long dealys we never risk skipping a metp (i.e. we never
 -- risk skipping a statement in timeline()
 
 writelog("SCH", "metp "..metp)
 
 -- log miscellaneous info
 log_info()
 
 -- see if anything is scheduled in timeline at metp
 scheduler(metp)

end

-- initialize timing mechanism
function init_time()
 somt = get_tick_count()
 metp=-1
 period_rollover=somt-1
 refresh_mets() 
end


function scheduler(t)
 -- sees what must happen at time t (expressed in periods)
 -- does not check at previous values of t (must therefore be called for each t)
 if timeline[t] then
  writelog("SCH", "Executing "..timeline[t]);
  torun=assert(loadstring(timeline[t]))
  torun()
 end
end
