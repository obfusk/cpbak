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

  These instructions assume that you've already setup e.g. srvbak on
  `rem`, with `chgrp_to=srvbak` and cron job, but have not yet added
  the srvbak user.

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
    #   command="./ssh-cmd.bash",no-agent-forwarding,
    #   no-port-forwarding,no-pty,no-X11-forwarding ...KEY...

    nasbak@nas$ vim .ssh/authorized_keys
    # on a single line, add:
    #   command="./ssh-cmd.bash",
    #   no-port-forwarding,no-pty,no-X11-forwarding ...KEY...

  Replace `...KEY...` with the contents of `cpbak@loc`'s
  `~/.ssh/id_rsa.pub`.

[]: }}}1

... TODO ...

### Cron
[]: {{{1

  Install the cpbak cron job on `loc`.  If you want reports per email,
  install mailer [3].

### Using cron.daily

    $ cp -i .../cpbak.cron.sample /etc/cron.daily/cpbak
    $ vim /etc/cron.daily/cpbak
    $ chmod +x /etc/cron.daily/cpbak

### With e.g. cron.4am

  Add the following line to /etc/crontab:

    25 2 * * * root  cd / && run-parts --report /etc/cron.4am

  Then:

    $ mkdir -p /etc/cron.4am
    $ cp -i .../cpbak.cron.sample /etc/cron.4am/cpbak
    $ vim /etc/cron.4am/cpbak
    $ chmod +x /etc/cron.4am/cpbak

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
