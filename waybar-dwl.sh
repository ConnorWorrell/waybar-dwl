#!/usr/bin/env bash
#
# wayar-dwl.sh - display dwl tags, layout, and active title
#
# USAGE: waybar-dwl.sh MONITOR COMPONENT
#        "COMPONENT" is an integer representing a dwl tag OR "layout" OR "title"
#
# REQUIREMENTS:
#  - inotifywait ( 'inotify-tools' on arch )
#  - Launch dwl with `dwl > ~.cache/dwltags` or change $fname
#
# Now the fun part
#
### Example ~/.config/waybar/config
#
# {
#   "modules-left": ["custom/dwl_tag#0", "custom/dwl_tag#1", "custom/dwl_tag#2", "custom/dwl_tag#3", "custom/dwl_tag#4", "custom/dwl_tag#5", "custom/dwl_layout", "custom/dwl_title"],
#   "custom/dwl_tag#0": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 0",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_tag#1": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 1",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_tag#2": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 2",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_tag#3": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 3",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_tag#4": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 4",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_tag#5": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 5",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_tag#6": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 6",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_tag#7": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 7",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_tag#8": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 8",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_tag#9": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' 9",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_layout": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' layout",
#     "format": "{}",
#     "return-type": "json"
#   },
#   "custom/dwl_title": {
#     "exec": "/xap/etc/waybar/waybar-dwl.sh '' title",
#     "format": "{}",
#     "return-type": "json"
#   }
# }
#
### Example ~/.config/waybar/style.css
# #custom-dwl_layout {
#     color: #EC5800
# }
#
# #custom-dwl_title {
#     color: #017AFF
# }
#
# #custom-dwl_tag {
#     color: #875F00
# }
#
# #custom-dwl_tag.selected {
#     color: #017AFF
# }
#
# #custom-dwl_tag.urgent {
#     background-color: #FF0000
# }
#
# #custom-dwl_tag.active {
#     border-top: 1px solid #EC5800
# }

# Variables
declare output title layout activetags selectedtags
declare -a tags name
readonly fname="$HOME"/.cache/dwltags

tags=( "1" "2" "3" "4" "5" "6" "7" "8" "9" )
name=( "" "" "" "" "" "" "7" "8" "9" ) # Array of labels for tags

monitor="${1}"
component="${2}"

_cycle() {
    case "${component}" in
	[012345])
	    this_tag="${component}"
	    unset this_status
	    mask=$((1<<this_tag))

	    if (( "${activetags}"   & mask )) 2>/dev/null; then this_status+='"active",'  ; fi
	    if (( "${selectedtags}" & mask )) 2>/dev/null; then this_status+='"selected",'; fi
	    if (( "${urgenttags}"   & mask )) 2>/dev/null; then this_status+='"urgent",'  ; fi

	    if [[ "${this_status}" ]]; then
		printf -- '{"text":" %s ","class":[%s]}\n' "${name[this_tag]}" "${this_status}"
	    else
		printf -- '{"text":" %s "}\n' "${name[this_tag]}"
	    fi
	    ;;
	layout)
	    printf -- '{"text":"  %s  "}\n' "${layout}"
	    ;;
	title)
	    printf -- '{"text":"%s"}\n' "${title}"
	    ;;
	*)
	    printf -- '{"text":"INVALID INPUT"}\n'
	    ;;
    esac
}

# Call the function here so the tags are displayed at dwl launch
_cycle

while true; do

    [[ ! -f "${fname}" ]] && printf -- '%s\n' \
				    "You need to redirect dwl stdout to ~/.cache/dwltags" >&2

    # Get info from the file
    output="$(grep "${monitor}" "${fname}" | tail -n4)"
    title="$(echo "${output}" | grep title | cut -d ' ' -f 3-  | sed s/\"/“/g )" # Replace quotation marks to prevent waybar crash
    #selmon="$(echo "${output}" | grep 'selmon')"
    layout="$(echo "${output}" | grep layout | cut -d ' ' -f 3- )"

    # Get the tag bit mask as a decimal
    activetags="$(echo "${output}" | grep tags | awk '{print $3}')"
    selectedtags="$(echo "${output}" | grep tags | awk '{print $4}')"
    urgenttags="$(echo "${output}" | grep tags | awk '{print $6}')"

    _cycle

    inotifywait -qq --event modify "${fname}"

done

unset -v output title layout activetags selectedtags
unset -v tags name

