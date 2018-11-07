rem snaps-source-001.bas -- https://github.com/CharlesNepote/snaps
rem .
rem **** Better use snaps-001.bas****, a version of this script without comments
rem => Explanation: http://chdk.wikia.com/wiki/CHDK_scripting says: It takes 10ms
rem    of time for each line of script to be interpreted by tiny uBASIC. 100 lines
rem    takes a full second, etc. This can greatly impact high-speed uses.
rem .
rem Rewrite of Anti-Motion Detector script aka Stillness Detector
rem Developed on A570IS by fudgey on Allbest #49. May work on any camera.
rem Free Software under GPL v3 Licence: https://chdk.setepontos.com/index.php/topic,1046.msg9260.html#msg9260
rem This script runs motion detection in a short loop and shoots if MD exits
rem due to timeout instead of motion.
rem Do not decrease compare interval below LCD refresh (possibly 30 ms)!
rem Do not decrease timeout below or even close to trigger delay!

rem Rewrote by Charles Nepote: throw out masking params; better readability
rem Note: To conserve batteries, plug an A/V cable to your A/V jack.
rem TODO: throw out columns and rows params?
rem TODO: force ISO 100?; force f/8?; turn off LCD to save batteries?
rem TODO: shoot raw? focus stacking to prevent blured photos?

rem Command line to manually produce snaps-001.bas with perl:
rem perl -0777pe 's/\n\n/\n/g;s/rem (.*)\n//g;' ./sources/snaps-source-001.bas > snaps-001.bas

@title SNAPS v0.0.1

rem Motion detection params
@param a Columns
@default a 6
@param b Rows
@default b 4
@param c Channel (0U,1Y,2V,3R,4G,5B)
@default c 1
rem d - the minimum period of non-motion indicating a new page has been placed (3 secs)
rem lower = more false photos ; higher = increased cycle time and growing impatience
@param d MD Timeout (*0.1s)
@default d 20
rem Compare interval : arc-simple.lua says : "less than 100 will slow down other CHDK functions"
@param e Compare Interval (*0.01s)
@default e 20
rem f - threshold (difference in cell to trigger detection)
rem ArchDoco.bas 8, arc-simpl.lua 5
@param f Threshold (0-255)
@default f 10

rem o - PIXELS STEP - Speed vs. Accuracy adjustments (1-use every pixel,2-use every second pixel, etc)
@param o Pixel Step (pixels)
@default o 4
rem p MILLISECONDS DELAY to begin triggering - can be useful for calibration with DRAW-GRID option.
@param p Trigger Delay (*0.1s)
@default p 1


rem Other params
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

rem  --- fast branch allows focus/exposure at startup, not after detection
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

rem --- slow branch allows focus/exposure after detection
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
