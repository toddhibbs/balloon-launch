-- FUNCTIONS FOR CUSTOM METERING
-- implements a statistic metering based on the "dark sky" principle


-- circular buffer holding the last Bv meterings

 bvtable={}
 bvtable_sorted={}
 bvtable_len=100
 bvtable_current=0 
 bvtable_ptr=0
 
-- read curent bv from scene
function read_bv96()
 press("shoot_half")
 while get_prop(115)==0 do
  sleep(100)
 end
 bv=get_bv96()
 release("shoot_half")
 return bv
end

 
-- insert a Bv value in the circular buffer
function feed_bvtable()
 dbg("Feed Bv Table")
 bvtable_current=bvtable_current+1
 bvtable_ptr = bvtable_current - bvtable_len*(bvtable_current/bvtable_len)
 bvtable[bvtable_ptr]=read_bv96()   
 writelog("MET", "Metered "..bvtable[bvtable_ptr])
end


-- returns an averaged bv from a specific range of bvtable's samples
-- range_lo and range_hi set start and end of range (in %)
-- for example, weighted_bv(90, 100) returns the average of the highest 10%
-- Bv meterings

function weighted_bv(range_lo, range_hi)

 
 bvtable_sorted=bvtable
 table.sort(bvtable_sorted)

 l=table.getn(bvtable_sorted)

 lo_sample=(l*range_lo)/100
 hi_sample=(l*range_hi)/100

 if hi_sample<lo_sample then
  hi_sample=lo_sample
 end

 tot=0
 samples=0 	
 for n=lo_sample, hi_sample do
  samples=samples+1
  tot=tot+bvtable_sorted[n]
 end
 
 tot=tot/samples

 dbg("Weighted bv "..tot)
 writelog("MET", "Calculated "..tot)
 return tot

end


function wait_for_light()
 repeat
  sleep(5000)
  print("Waiting for start...")
  t=read_bv96()
 until t>0
 print("Started!")
end

