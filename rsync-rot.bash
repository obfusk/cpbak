#!/bin/bash

# --                                                            ; {{{1
#
# File        : rsync-rot.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-05-26
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

set -e
export LC_COLLATE=C
date="$( date +'%FT%T' )"   # no spaces!
usage='rsync-rot.bash <n> <from> <base_dir> <arg(s)>'

# --

# Usage: die <msg(s)>
function die () { echo "$@" >&2; exit 1; }

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
function grep0 () { grep "$@" || [ "$?" -eq 1 ]; }

# Usage: head_neg <K>
# Print all but the last $K lines of STDIN, like GNU head -n -$K.
function head_neg ()
{                                                               # {{{1
  local -i k="$1" n i ; local lines=() line
  while IFS= read -r line; do lines+=( "$line" ); done
  n="$(( ${#lines[@]} - k ))"
  for (( i = 0; i < n; ++i )); do printf '%s\n' "${lines[i]}"; done
}                                                               # }}}1

# --

# Usage: ls_backups <dir>
function ls_backups () { ls "$1" | grep0 -E '^[0-9]{4}-'; pipe_ckh; }

# Usage: last_backup <dir>
function last_backup () { ls_backups "$1" | tail -n 1; pipe_ckh; }

# Usage: obsolete_backups <dir>
# NB: b/c busybox has no `head -n -$K` we use head_neg instead.
function obsolete_backups ()
{ ls_backups "$1" | head_neg "$keep_last"; pipe_ckh; }

# Usage: cp_last_backup <dir> <path>
# Copies last backup in <dir> (if one exists) to <path> using hard
# links.
# NB: call before new backup (or dir creation)!
# NB: b/c busybox has no `cp -T` we `rm -rf <path>` before copying.
function cp_last_backup ()
{                                                               # {{{1
  local dir="$1" path="$2" ; local last="$( last_backup "$dir" )"
  if [ -n "$last" -a -e "$dir/$last" ]; then
    run rm -fr "$path"
    run cp -al "$dir/$last" "$path"
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
keep_last="$1" from="$2" base_dir="$3" ; shift 3
to="$base_dir/$date"

run mkdir -p "$base_dir"
cp_last_backup "$base_dir" "$to"
run rsync "$@" "$from"/ "$to"/
rm_obsolete_backups "$base_dir"

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
