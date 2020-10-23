# ffmpeg-Video-Clipper
Bash script that leverages ffmpeg's video clipping capability and provides two methods for clipping video: Slow to process but accurate video clips and Quick to process but final output includes some additional content from the original input.

Requirements:
ffmpeg

sudo apt install ffmpeg

Input format should be as such:
ClipVid.sh <input video> <start timecode> <end timecode> a(optional)

Start and end timecodes should be hour:minute:second 
(eg. 01:02:03 would represent the 1 hour, 2 minute, and 3 second timecode)

The optional 'a' tells the script to be accurate with the clipping. Re-encoding will occur. Depending on your equipment and video size this could take awhile. The re-encoding is essentially re-establishing the key frames. Which will prevent the first part of the video from being blank. 

Excluding the 'a' will perform a quick video clip. Which is great for large videos. It will find the last key frame that appeared before the selected <start timecode> and use that as the start of the video clip.
