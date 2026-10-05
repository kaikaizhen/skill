# Target: VM + systemd

Single host running the published app directly - no container, no registry. When to
pick it: `decision-rules.md` §6.

## 1. Host layout

```
/opt/<app>/
├── releases/
│   ├── <sha-old>/          # previous published outputs, kept for rollback
│   └── <sha-new>/
└── current -> releases/<sha-new>     # symlink; the unit runs from here
/etc/<app>/<app>.env                  # config + secrets, root:root 0600
```

Keep the last 5 releases; the deploy job deletes older ones **only inside
`/opt/<app>/releases/`**.

## 2. Publish mode

- **Framework-dependent** (default when the host has, or the user will install, the
  matching .NET runtime): `dotnet publish -c Release -o publish`.
- **Self-contained** (`-r linux-x64 --self-contained -p:PublishSingleFile=true`) when
  the host must not need a runtime. Larger artifact; state the choice.
- Build on CI runners, never on the host.

## 3. Unit file (`deploy/<app>.service` in the repository)

```ini
[Unit]
Description=<app>
After=network-online.target
Wants=network-online.target

[Service]
Type=simple                       # notify only if the app already calls UseSystemd()
User=<app>
Group=<app>
WorkingDirectory=/opt/<app>/current
ExecStart=/usr/bin/dotnet /opt/<app>/current/<Assembly>.dll   # or the single-file binary
EnvironmentFile=/etc/<app>/<app>.env
Environment=ASPNETCORE_ENVIRONMENT=<Env>
Environment=ASPNETCORE_URLS=http://127.0.0.1:<port>   # <port>: stacks/dotnet.md §1.1
Restart=always
RestartSec=5
TimeoutStopSec=45
KillSignal=SIGTERM
NoNewPrivileges=true
ProtectSystem=full
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

- `<port>` comes from evidence (existing unit / reverse-proxy upstream / app config /
  user). Kestrel's built-in default when nothing is configured is not evidence of the
  intended port: `Unknown` -> Gate 7 (`decision-rules.md` §9). If the app's own
  configuration already sets its URLs, omit `ASPNETCORE_URLS` instead of overriding.
- Dedicated non-login user `<app>`; never root.
- Bind to `127.0.0.1` behind an existing reverse proxy; a public bind only if the user
  says the app is exposed directly. Reverse-proxy configuration is out of scope unless
  the repository already contains it.
- `Type=notify` requires `Microsoft.Extensions.Hosting.Systemd` + `UseSystemd()` - an
  application change (Gate 2); default to `Type=simple`.
- Scheduled Job: a `<app>-<job>.service` with `Type=oneshot` plus a `<app>-<job>.timer`
  (`OnCalendar=`, `Persistent=true`) instead of cron.

## 4. Deploy job (from CI over SSH)

```bash
tar czf <app>-<sha>.tar.gz -C publish .
scp <app>-<sha>.tar.gz "$DEPLOY_USER@$DEPLOY_HOST:/tmp/"
ssh "$DEPLOY_USER@$DEPLOY_HOST" '
  set -euo pipefail
  dest=/opt/<app>/releases/<sha>
  mkdir -p "$dest" && tar xzf /tmp/<app>-<sha>.tar.gz -C "$dest" && rm /tmp/<app>-<sha>.tar.gz
  ln -sfn "$dest" /opt/<app>/current.new && mv -T /opt/<app>/current.new /opt/<app>/current
  sudo systemctl restart <app>
  ls -1dt /opt/<app>/releases/*/ | tail -n +6 | xargs -r rm -rf --
'
<systemctl is-active + smoke test with retries; fail the job otherwise>
```

- The tarball is the artifact built once in the package job and promoted; the deploy
  job does not run `dotnet publish`.
- Symlink swap via `mv -T` is atomic.
- Restart = brief downtime on a single host; say so in the Assessment.

## 5. Manual setup (Report)

Install the .NET runtime (framework-dependent); create user `<app>`; create
`/opt/<app>/releases` owned by the deploy user and readable by `<app>`; create
`/etc/<app>/<app>.env` (0600); copy and enable the unit once
(`systemctl enable <app>`); sudoers entry allowing the deploy user **only**
`systemctl restart <app>` (and `daemon-reload` if the unit file is redeployed); CI
variables from `ci/<provider>.md` §5.

Redeploying the unit file itself from CI is optional; if generated, the job copies it
to `/etc/systemd/system/` and runs `daemon-reload` - needs the wider sudoers rule, so
list it explicitly.

## 6. Rollback

```bash
ssh <host> 'readlink /opt/<app>/current; ls -1t /opt/<app>/releases'
ssh <host> 'ln -sfn /opt/<app>/releases/<previous sha> /opt/<app>/current.new && mv -T /opt/<app>/current.new /opt/<app>/current && sudo systemctl restart <app>'
```

Then `systemctl is-active <app>` and the smoke test. Releases beyond the retained 5 are
gone: re-run that commit's deploy job (its CI artifact must still exist).
