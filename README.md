[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2013-05-28

    Copyright   : Copyright (C) 2013  Felix C. Stegerman
    Version     : 0.2.0-dev

[]: }}}1

## TODO

  * write! + review! + test!

    $ rsync -e 'ssh -p 2222' -av --delete test@localhost:__foo__/ \
      ./__foo__/
    LOCK
    ...
    UNLOCK

## Description
[]: {{{1

  cpbak - copy server backup (to e.g. a nas) using rsync + ssh (cron
  job)

  cpbak is a set of scripts and templates for the following scenario:

  You have a remote server (`rem`) with a backup (e.g. srvbak [2])
  cron job (that runs at e.g. 2am); a local server (`loc`) with a
  cpbak cron job (that runs at e.g. 4am); and a local file server
  (`nas`).

  The cpbak cron job on `loc` uses ssh to log in to `nas` and use
  rsync to copy the backup on `rem` to `nas`.  It uses ssh agent
  forwarding to temporarily allow `nas` to access `rem`.

  In case you also want to copy backups on `loc` to `nas`, you can
  just use cpbak with `rem`=`loc`.

  You may be able to adapt cpbak to other (similar) scenarios as well.

[]: }}}1

## Install and Configure

[]: {{{1

  These instructions assume that you've already setup e.g. srvbak on
  `rem`, with `chgrp_to=srvbak` and cron job, but have not yet added
  the srvbak user.

  Replace `$REM` w/ the name of the backup host (`rem` in the
  example); repeat the instructions for `rem` for all backup hosts if
  there is more than one.

[]: }}}1

### Clone

  Clone the cpbak repository on `loc`:

    $ mkdir -p /opt/src
    $ git clone https://github.com/noxqsgit/cpbak.git /opt/src/cpbak

### Users
[]: {{{1

    loc$  adduser --system --group --shell /bin/bash \
            --home /var/lib/cpbak --disabled-password cpbak

    rem$  adduser --system --group --shell /bin/bash \
            --home /var/lib/srvbak --disabled-password srvbak

    nas$  adduser --system --group --shell /bin/sh \
            --home /var/lib/nasbak --disabled-password nasbak
          # or something equivalent

[]: }}}1

### Keys
[]: {{{1

    cpbak@loc$  ssh-keygen    # no password

    srvbak@rem$ ssh-keygen    # no password
    srvbak@rem$ vim .ssh/authorized_keys
    # on a single line, add:
    #   command="./bin/ssh-cmd.bash",no-agent-forwarding,
    #   no-port-forwarding,no-pty,no-X11-forwarding ...KEY...

    nasbak@nas$ vim .ssh/authorized_keys
    # on a single line, add:
    #   command="./bin/ssh-cmd.bash",
    #   no-port-forwarding,no-pty,no-X11-forwarding ...KEY...

  Replace `...KEY...` with the contents of `cpbak@loc`'s
  `~/.ssh/id_rsa.pub`.

[]: }}}1

### srvbak (un)locking
[]: {{{1

  When using srvbak, on `rem`:

    $ cd /opt/src/srvbak
    $ cp -i srvbak.sudoers.sample /etc/sudoers.d/srvbak
    $ cp -i srvbak-lock.bash{.sample,}
    $ cp -i srvbak-unlock.bash{.sample,}
    $ chmod +x srvbak-{,un}lock.bash
    $ vim srvbak-{,un}lock.bash   # set base_dir

[]: }}}1

### Scripts
[]: {{{1

#### srvbak@rem

    $ mkdir -p ~/bin
    $ cp -i .../ssh-cmd.srvbak.sample ~/bin/ssh-cmd
    $ chmod +x ~/bin/ssh-cmd

#### nasbak@nas

    $ mkdir -p ~/bin
    $ cp -i .../rsync-rot.bash ~/bin/
    $ cp -i .../ssh-cmd.nasbak.sample ~/bin/ssh-cmd
    $ vim ~/bin/ssh-cmd
    $ chmod +x ~/bin/ssh-cmd

Replace `$REM` w/ the name of the backup host(s) (e.g. `rem`).

    $ cp -i .../cpbak.bash.sample ~/bin/cpbak/cpbak-$REM.bash
    $ vim ~/bin/cpbak-$REM.bash
    $ chmod +x ~/bin/cpbak-$REM.bash

[]: }}}1

### Cron
[]: {{{1

  Install the cpbak cron job(s) on `loc`.  Replace `$REM` w/ the name
  of the backup host(s) (e.g. `rem`).  If you want reports per email,
  install mailer [3].

    $ cp -i /opt/src/cpbak/cpbak-cron.bash.sample \
      /opt/src/cpbak/cpbak-cron-$REM.bash
    $ vim /opt/src/cpbak/cpbak-cron-$REM.bash
    $ chmod +x /opt/src/cpbak/cpbak-cron-$REM.bash

### Either using cron.daily

    $ cp -i /opt/src/cpbak/cpbak.cron.rem.sample \
      /etc/cron.daily/cpbak-$REM
    $ vim /etc/cron.daily/cpbak-$REM
    $ chmod +x /etc/cron.daily/cpbak-$REM

### or with e.g. cron.4am
[]: {{{2

  Add the following line to /etc/crontab:

    25 2 * * * root  cd / && run-parts --report /etc/cron.4am

  And:

    $ mkdir -p /etc/cron.4am

  Then:

    $ cp -i /opt/src/cpbak/cpbak.cron.rem.sample \
      /etc/cron.4am/cpbak-$REM
    $ vim /etc/cron.4am/cpbak-$REM
    $ chmod +x /etc/cron.4am/cpbak-$REM

[]: }}}2

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
