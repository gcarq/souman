#!/bin/bash -e

##
# Constants
##
_version="%%VERSION%%"
workdir="$HOME/.cache/souman"

##
# Script Exit Reasons
# -------------------
#              E_OK : Everything worked :)
# E_MISSING_PROGRAM : A program the script depends on is not installed.
#    E_CONFIG_ERROR : Missing/incorrect configuration.
#  E_INVALID_OPTION : User has passed unknown/invalid option to script.
##
_E_OK=0
_E_MISSING_PROGRAM=1
_E_CONFIG_ERROR=2
_E_INVALID_OPTION=3

##
# Consistent messaging format
##
msg() {
	local mesg=$1; shift
	printf "==> ${mesg}\n" "$@"
}

error() {
	local mesg=$1; shift
	printf  "error: ${mesg}\n" "$@" >&2
}

##
# Helper functions
##
usage() {
	echo "Arch Source Manager $_version -- source synchronization and building utility"
	echo ""
	echo "Usage:"
	echo "$0 [options] [package [package ...]]"
	echo
	echo "Options:"
	echo "  -h, --help     Display this help message then exit."
	echo "  -V, --version  Display version information then exit."
	echo "  -y, --refresh  Sync repositories using ABS."
	echo
	echo "If no argument is given, souman will search in ${workdir} for synced repositories."
	echo "The sync is completely managed by abs, so you may want to edit /etc/abs.conf."
}

version() {
	echo "souman $_version"
	echo
	echo "Copyright (C) 2017 gcarq <michael.egger@tsn.at>"
	echo
	echo "This is free software; see the source for copying conditions."
	echo "There is NO WARRANTY, to the extent permitted by law."
}

##
# Invoke makepkg for all $_packages
##
build_packages() {
	for package in "${_packages[@]}"; do
		tmp_workdir="$(mktemp -d -t "$(basename "$0").XXXXXX")"
		# get a folder path from find(1)
		abs_dir="$(find "$workdir" -maxdepth 2 -type d -name "$package")"
		# find(1) will not err if it returns nothing, thus the following -d test
		if [[ -d "${abs_dir}" ]]; then
			cp -R "${abs_dir}/." "$tmp_workdir/"
			cd "$tmp_workdir"
			makepkg --syncdeps --install --clean
		else
			error "target not found: $package"
		fi
		cd
		rm -r "$tmp_workdir"
	done
}


##
# Signal Traps
##
trap 'error "TERM signal caught. Exiting..."; exit 1' TERM HUP QUIT
trap 'error "Aborted by user! Exiting..."; exit 1' INT
trap 'error "An unknown error has occured. Exiting..."; exit 1' ERR

##
# Dont allow root user to run this script
##
if [[ "$EUID" -eq 0 ]];then
	error "Running souman as root is not allowed as it can cause permanent, catastrophic damage to your system."
	exit $_E_INVALID_OPTION;
fi

##
# Parse Options
##
opt_short="hVy"
opt_long="help,version,refresh"
opt_temp="$(getopt -o "$opt_short" -l "$opt_long" -n "$(basename "$0")" -- "$@" || echo 'GETOPT GO BANG!')"
if echo "$opt_temp" | grep -q 'GETOPT GO BANG!'; then
	# This is a small hack to stop the script bailing with 'set -e'
	echo; usage; exit $_E_INVALID_OPTION;
fi
eval set -- "$opt_temp"
unset opt_short opt_long opt_temp

while true; do
	case "$1" in
		-h|--help)     usage; exit $_E_OK;;
		-V|--version)  version; exit $_E_OK;;
		-y|--refresh)  _refresh=1;;
		--)            OPT_IND=0; shift; break;;
		*)             usage; exit $_E_INVALID_OPTION;;
	esac
	shift
done

if [[ "$#" -gt "0" ]]; then
	CLPARAM=1
	_packages=("$@")
fi

if [[ -z "$_packages" ]] && [[ -z "$_refresh" ]]; then
    usage >&2; exit $_E_INVALID_OPTION;
fi

if [[ ! -d "$workdir" ]]; then
	mkdir -p "$workdir"
fi

if [[ ! -w "$workdir" ]]; then
	error "no write permissions in $workdir"
	exit $_E_CONFIG_ERROR
fi

if [[ "$_refresh" ]]; then
	# invoke abs to sync repos
	ABSROOT="$workdir" abs -t
fi

if [[ "$_packages" ]]; then
    build_packages;
fi

exit $_E_OK

# vim: set ts=2 sw=2 noet:
