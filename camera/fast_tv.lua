-- Fast TV shooting

-- Fast Tv mode is defined as a Tv mode where 
-- we try to attain a VERY fast shutter time (like 1/5000")
-- by increasing ISO
-- There is anyway a maximum value for ISO

function fast_tv_shoot(bv, fast_tv, max_sv, offset)
-- bv is the brightness we suppose have in the scene
-- if bv=-1 this means we will have to meter ourselves
-- fast_tv is the shutter time we would like to attain
-- max_sv is the maximun sensibility we find acceptable 
-- offset is a fine-tining for very fast exposures

-- Possibile values for fast_tv
-- 1245 = 1/8000
-- 1149 = 1/4000
-- 1053 = 1/2000
--  957 = 1/1000
--  861 =  1/500
--  765 =  1/250

-- Possible values of max_sv
-- 320 = ISO   50
-- 388 = ISO   80
-- 418 = ISO  100
-- 514 = ISO  200
-- 611 = ISO  400
-- 707 = ISO  800
-- 803 = ISO 1600

-- Ixus 80 has fixed aperture
av = 285 + offset
--av = 143

dbg("FAST TV")
dbg("bv " .. bv)


if bv==-1 then
 bv=read_bv96()
 dbg("metered bv " .. bv)
 -- offset measured brightness
end

--if we shoot at fast_tv,
tv=fast_tv
-- resulting sv would be
sv = av + fast_tv - bv 

dbg("tv " .. tv)
dbg("sv " .. sv)

-- let's check if it's not too high
if sv>max_sv then 
 -- how much must we reduce sv?
 reduce = sv-max_sv
 -- same reduction must be added to tv
 tv=tv-reduce 
 sv=max_sv
 dbg("Reduced: ")
 dbg("tv " .. tv)
 dbg("sv " .. sv)
end 

-- it might also happen than sv goes too low
-- arbitrary limit of 322 sv (abt ISO 50)
if sv<322 then 
 reduce = sv-322
 tv=tv-reduce 
 sv=322
 dbg("INCREASED: ")
 dbg("tv " .. tv)
 dbg("sv " .. sv)
end 


-- at last moment, set our parameters


-- set shutter time
set_tv96_direct(tv) 
sleep(100)

-- set ISO
set_sv96(sv)
sleep(100)

shoot()

writelog("FTV", "Shoot " .. get_exp_count() .. " ".. bv .. " " .. tv .. " " .. sv .. " " .. av)

repeat
 sleep(100)
until get_prop(206)==0

end
