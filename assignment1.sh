#!/bin/bash

# This script is for our first assignment, create a system report. #
# Started on October 9th, 2024 by Steven Kouzoukas. #
# echo "System report generated by $USER, on $(date)."

# Place date into variables #
myusername="$USER"
currentdatetime="$(date)"

# grabbing the distro name and version from /etc/os-release for easy access. #
#If a distro doesn't have this file, it won't work :( #
source /etc/os-release
mydistro="$PRETTY_NAME"

### Create the report itself from a template.
cat <<EOF

System report generated by $myusername, $currentdatetime.
$mydistro

EOF
