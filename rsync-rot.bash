#!/bin/bash

# TODO TODO TODO TODO TODO

# --                                                            ; {{{1
#
# File        : rsync-rot.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-05-23
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

set -e
export LC_COLLATE=C
date="$( date +'%FT%T' )"   # no spaces!
usage='rsync-rot.bash <n> <to> <arg(s)>'

# --

# Usage: die <msg(s)>
function die () { echo "$@" 2>&1; exit 1; }

# Usage: run <cmd> <arg(s)>
function run () { echo "==> $@"; "$@"; echo; }

# Usage: pipe_ckh [<msg(s)>]
function pipe_ckh ()
{                                                               # {{{1
  local ps=( "${PIPESTATUS[@]}" ) x
  for x in "${ps[@]}"; do
    [ "$x" -eq 0 ] || die 'non-zero PIPESTATUS' "$@"
  done
}                                                               # }}}1

# Usage: grep0 [<arg(s)>]
# Runs grep <arg(s)> but returns 0 if grep returned 0 or 1; and 1 if
# grep returned something else.  Thus, only returns non-zero if grep
# actually failed, not if it simply found nothing.
function grep0 () { grep "$@" || [ "$?" -eq 1 ]; }

# --

# Usage: ls_backups <dir>
function ls_backups () { ls "$1" | grep0 -E '^[0-9]{4}-'; pipe_ckh; }

# Usage: last_backup <dir>
function last_backup () { ls_backups "$1" | tail -n 1; pipe_ckh; }

# Usage: obsolete_backups <dir>
function obsolete_backups ()
{ ls_backups "$1" | head -n -"$keep_last"; pipe_ckh; }

# Usage: cp_last_backup <dir> <path>
# Copies last backup in <dir> (if one exists) to <path> using hard
# links.
# NB: call before new backup (or dir creation)!
function cp_last_backup ()
{                                                               # {{{1
  local dir="$1" path="$2" ; local last="$( last_backup "$dir" )"
  if [ -n "$last" -a -e "$dir/$last" ]; then
    run cp -alT "$dir/$last" "$path"
  fi
}                                                               # }}}1

# Usage: rm_obsolete_backups <dir>
# NB: call after new backup!
function rm_obsolete_backups ()
{                                                               # {{{1
  local dir="$1" x
  for x in $( obsolete_backups "$dir" ); do
    run rm -fr "$dir/$x"
  done
}                                                               # }}}1

# --

[ "$#" -lt 3 ] && die "Usage: $usage"
keep_last="$1" base_dir="$2" ; shift 2 ; to="$base_dir/$date"

run mkdir -p "$to"
cp_last_backup "$base_dir" "$to"
run rsync "$@" "$to"/
rm_obsolete_backups "$base_dir"

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
