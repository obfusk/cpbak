[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2013-05-28

    Copyright   : Copyright (C) 2013  Felix C. Stegerman
    Version     : 0.2.0-dev

[]: }}}1

## TODO

  * write! + review! + test!
  * 2am/4am/...

## Description
[]: {{{1

  cpbak - copy server backup (to e.g. a nas) using rsync + ssh (cron
  job)

  cpbak is a set of scripts and templates for the following scenario:

  You have a remote server (rem) with a backup (e.g. srvbak [2]) cron
  job (that runs at e.g. 2am); a local server (loc) with a cpbak cron
  job (that runs at e.g. 4am); and a local file server (nas).

  The cpbak cron job on loc uses ssh to log in to nas and use rsync to
  copy the backup on rem to nas.  It uses ssh agent forwarding to
  temporarily allow nas to access rem.

  In case you also want to copy backups on loc to nas, you can just
  use cpbak with rem=loc.

  You may be able to adapt cpbak to other (similar) scenarios as well.

[]: }}}1

## Install and Configure
[]: {{{1

  ...

[]: }}}1

## Run
[]: {{{1

  ...

[]: }}}1

## Cron
[]: {{{1

  ... mailer [3] ...

  ...

[]: }}}1

## License
[]: {{{1

  GPLv2 [1].

[]: }}}1

## References
[]: {{{1

  [1] GNU General Public License, version 2
  --- http://www.opensource.org/licenses/GPL-2.0

  [2] srvbak
  --- https://github.com/noxqsgit/srvbak

  [3] mailer
  --- https://github.com/noxqsgit/mailer

[]: }}}1

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
