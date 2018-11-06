@title SNAPS v0.0.1
@param a Columns
@default a 6
@param b Rows
@default b 4
@param c Channel (0U,1Y,2V,3R,4G,5B)
@default c 1
@param d MD Timeout (*0.1s)
@default d 20
@param e Compare Interval (*0.01s)
@default e 20
@param f Threshold (0-255)
@default f 10
@param o Pixel Step (pixels)
@default o 4
@param p Trigger Delay (*0.1s)
@default p 1

@param r Burst/Review time (s)
@default r 0
@param s Slow Shoot (0=No 1=Yes)
@default s 0
if a<1 then a=1
if b<1 then b=1
if c<0 then c=1
if c>5 then c=1
if c=0 then print "Channel: U chroma"
if c=1 then print "Channel: Luminance"
if c=2 then print "Channel: V chroma"
if c=3 then print "Channel: Red"
if c=4 then print "Channel: Green"
if c=5 then print "Channel: Blue"
if d<1 then d=1
d=d*100
p=p*100
if r<0 then r=0
r=r*1000
if s>0 then goto "slow_anti_md"
press "shoot_half"
:fast_anti_md
do
  h=0
  md_detect_motion a, b, c, d, e, f, 1, h, 0, 0, 0, 0, 0, 0, o, p
until h<1
press "shoot_full"
let X=get_tick_count
:contloop1
let U=get_tick_count
let V=(U-X)
if V<r then goto "contloop1"
release "shoot_full"
goto "fast_anti_md"
:slow_anti_md
do
  h=0
  md_detect_motion a, b, c, d, e, f, 1, h, 0, 0, 0, 0, 0, 0, o, p
until h<1
if r>1 then goto "contshoot2" else shoot
goto "slow_anti_md"
:contshoot2
press "shoot_full"
let X=get_tick_count
:contloop2
let U=get_tick_count
let V=(U-X)
if V<r then goto "contloop2"
release "shoot_full"
goto "slow_anti_md"
