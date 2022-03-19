# waybar-dwl.sh

waybar-dwl.sh generates [dwl](https://github.com/djpohly/dwl) tag, layout and title info for [waybar](https://github.com/Alexays/Waybar)
----------------------------------------------------------------------------------------------------------------------------------------

waybar-dwl.sh is based heavily upon [dwl-tags.sh](https://codeberg.org/novakane/yambar/src/branch/master/examples/scripts/dwl-tags.sh) by user "novakane" (Hugo Machet) that does same job for [yambar](https://codeberg.org/dnkl/yambar)



REQUIREMENTS:
 - inotifywait ( 'inotify-tools' on arch )
 - Launch dwl with `dwl > ~.cache/dwltags` or change $fname
 - Modify "tags" array if you use fewer than nine tags
 - Modify "name" array with your choice of labels
 - See waybar-dwl.sh comments for usage details
