[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-04-01

    Copyright   : Copyright (C) 2013  Felix C. Stegerman
    Version     : 0.4.4

[]: }}}1

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

  By default cpbak uses `rsync-rot.bash` to create a rotating,
  incremental backup.  Backups are kept in timestamped directories
  inside a base directory on `nas`.  First, the last backup (if any)
  is copied to the location of the new backup, using hard links; then
  rsync is run; afterwards obsolete backups are removed.

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
    $ git clone https://github.com/obfusk/cpbak.git /opt/src/cpbak

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

    srvbak@rem$ vim .ssh/authorized_keys
    # on a single line, add:
    #   command="./bin/ssh-cmd.sh",no-agent-forwarding,
    #   no-port-forwarding,no-pty,no-X11-forwarding ...KEY...

    nasbak@nas$ vim .ssh/authorized_keys
    # on a single line, add:
    #   command="./bin/ssh-cmd.sh",
    #   no-port-forwarding,no-pty,no-X11-forwarding ...KEY...

    cpbak@loc$  echo 'PasswordAuthentication = no' >> .ssh/config
    nasbak@nas$ echo 'PasswordAuthentication = no' >> .ssh/config

    cpbak@loc$  ssh nasbak@nas FAIL   # confirm fingerprint
    nasbak@nas$ ssh srvbak@rem FAIL   # confirm fingerprint

  Replace `...KEY...` with the contents of `cpbak@loc`'s
  `~/.ssh/id_rsa.pub`.

[]: }}}1

### srvbak (un)locking
[]: {{{1

#### BE CAREFUL

  Modifying sudoers files can be dangerous as it can make sudo
  unusable; use `visudo -c -f file` to check the syntax of a sudoers
  file before copying it to e.g. /etc/sudoers.d; use `visudo -f file`
  to edit a sudoers file safely.

  When using srvbak, on `rem`:

    $ cd /opt/src/srvbak
    $ cp -i srvbak.sudoers.sample /etc/sudoers.d/srvbak
    $ chmod 440 /etc/sudoers.d/srvbak
    $ cp -i srvbak-lock.bash{.sample,}
    $ cp -i srvbak-unlock.bash{.sample,}
    $ chmod +x srvbak-{,un}lock.bash
    $ vim srvbak-{,un}lock.bash   # set base_dir

[]: }}}1

### Scripts
[]: {{{1

#### srvbak@rem

    $ mkdir -p ~/bin
    $ cp -i .../ssh-cmd.sh.srvbak.sample ~/bin/ssh-cmd.sh
    $ vim ~/bin/ssh-cmd.sh
    $ chmod +x ~/bin/ssh-cmd.sh

#### nasbak@nas

    $ mkdir -p ~/bin
    $ cp -i .../rsync-rot.bash ~/bin/
    $ cp -i .../ssh-cmd.sh.nasbak.sample ~/bin/ssh-cmd.sh
    $ vim ~/bin/ssh-cmd.sh
    $ chmod +x ~/bin/ssh-cmd.sh

Replace `$REM` w/ the name of the backup host(s) (e.g. `rem`).

    $ cp -i .../cpbak.bash.sample ~/bin/cpbak-$REM.bash
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

    $ mkdir -p /etc/cron.4am
    $ cp -i /opt/src/cpbak/crontab.4am.sample /etc/cron.d/4am

  Then:

    $ cp -i /opt/src/cpbak/cpbak.cron.rem.sample \
      /etc/cron.4am/cpbak-$REM
    $ vim /etc/cron.4am/cpbak-$REM
    $ chmod +x /etc/cron.4am/cpbak-$REM

[]: }}}2

[]: }}}1

## Logrotate
[]: {{{1

  If you (use the cron job to) write to e.g. `/var/log/cpbak/*.log` on
  `loc`, you may want to use logrotate.

    $ cp -i /opt/src/cpbak/cpbak.logrotate.sample \
      /etc/logrotate.d/cpbak

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
  --- https://github.com/obfusk/srvbak

  [3] mailer
  --- https://github.com/obfusk/mailer

[]: }}}1

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
