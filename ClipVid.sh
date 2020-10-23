#!/bin/bash

#https://superuser.com/questions/554620/how-to-get-time-stamp-of-closest-keyframe-before-a-given-timestamp-with-ffmpeg
function ffnearest() {
  STIME=$2; export STIME;
  ffprobe -read_intervals $[$STIME-25]% -select_streams v -show_frames -show_entries frame=pkt_pts_time,pict_type -v quiet "$1" |
  awk -F= '
    /pict_type=/ { if (index($2, "I")) { i=1; } else { i=0; } }
    /pkt_pts_time/ { if (i && ($2 <= ENVIRON["STIME"])) print $2; }
    /pkt_pts_time/ { if (i && ($2 > ENVIRON["STIME"])) exit 0; }
  ' | tail -n 1
}

vidname=$1
Input_Start_vtc=$2
Input_End_vtc=$3
Input_Method=$4

# step=10
# img="${vidname}.bmp"

IFS=":" read -a Input_Start_vtc_arr <<<$Input_Start_vtc
# echo "${Input_Start_vtc_arr[@]}"
# echo "Number of elements: ${#Input_Start_vtc_arr[@]}"
# echo "first entry: ${Input_Start_vtc_arr[0]}"
# echo "second entry: ${Input_Start_vtc_arr[1]}"
# echo "third entry: ${Input_Start_vtc_arr[2]}"

S_hours=${Input_Start_vtc_arr[0]}
S_min=${Input_Start_vtc_arr[1]}
S_sec=${Input_Start_vtc_arr[2]}

startvtcsec=$(bc -l <<<"$S_hours * 3600 + $S_min * 60 + $S_sec")

IFS=":" read -a Input_End_vtc_arr <<<$Input_End_vtc
E_hours=${Input_End_vtc_arr[0]}
E_min=${Input_End_vtc_arr[1]}
E_sec=${Input_End_vtc_arr[2]}
endvtcsec=$(bc -l <<<"$E_hours * 3600 + $E_min * 60 + $E_sec")
# echo "endvtcsec: ${endvtcsec}"
ClipLen=$(bc -l <<<"$endvtcsec - $startvtcsec")
# echo "ClipLen: ${ClipLen}"
# Prestep=$(bc -l <<< "${startvtcsec} - 10")
# echo "Prestep: ${Prestep}"
if [[ ${ClipLen} -gt 0 ]]
then
	if [ "${Input_Method}" == "a" ]
	then 
		echo accurate method selected
		outputVidName="${startvtcsec}_${vidname}"
		# echo "outputVidName: ${outputVidName}"
		#accurate but takes a while to encode
		ffmpeg -ss ${Input_Start_vtc} -i "${vidname}" -to ${Input_End_vtc} -c:a copy "${outputVidName}"
	else
		echo quick method selected
		#quick but includes earlier time to resolve missing keyframe
		#ffnearest "${vidname}" "${startvtcsec}"
		key_before_startvtcsec=$(ffnearest "${vidname}" "${startvtcsec}")
		# echo "${key_before_startvtcsec}"
		# add in difference between startvtc and key startvtc
		ClipLen=$(bc -l <<<"${endvtcsec} - ${key_before_startvtcsec} + 1")
		outputVidName="${key_before_startvtcsec}_${vidname}"
		ffmpeg -ss $(bc -l <<<"${key_before_startvtcsec} - 1") -i "${vidname}" -t ${ClipLen} -c:a copy -c:v copy "${outputVidName}"
	fi
fi