# Nginx Policy

One conf per project, outside the project directory:

```
<nginx_conf_dir>/<project-folder>.conf
```

The Nginx deployment is shared infrastructure. This skill touches **only** that one
file for the project being deployed - never another project's conf, never the main
`nginx.conf`, never the Nginx compose.

## 1. Locate Nginx (read-only)

From `workspace/deploy.yaml`:

```yaml
nginx: { base_domain: <domain>, container: <name>, network: <docker network> }
```

Confirm the container is running and learn how to test it before relying on it:
`docker ps` for the container, `docker exec <container> nginx -t` as the syntax test
("or the equivalent for that deployment" - if it is not a container, the config test
the Nginx deployment itself uses). Not locatable -> ask; do not guess a container
name or reload the wrong process.

## 2. NEW project - generate

Inputs: `subdomain` (asked), `base_domain` (settings), `service port` and the service
name / container name Nginx will reach.

1. Read one or two existing confs in `conf.d/` and match their conventions (listen
   ports, TLS / certificate handling, proxy headers, log paths). The template
   `templates/nginx.conf.template` is the default shape, not an override of what the
   real deployment already does.
2. Fill the template: `server_name <subdomain>.<base_domain>`, upstream
   `<service>:<port>` over the shared `nginx.network`.
3. The app's compose attaches to that same external network so the name resolves.
4. Refuse if `conf.d/<folder>.conf` already exists for a NEW project - that is an
   unknown existing config (STOP, ask), not something to overwrite.

Also check `server_name` is not already claimed by another conf in `conf.d/`
(`grep -l`). A duplicate is reported and stops the run.

## 3. UPDATE - change only what must change

Read the existing conf first. If the upstream and name are unchanged, leave the file
**alone**. When it must change: back it up (§4), then edit.

## 4. Safety flow - never reload an unverified config

```
Generate new config
  -> Back up the existing config          <project>/backup/<backup-id>/nginx/
  -> Install the new config
  -> nginx -t (container equivalent)
  -> PASS -> reload        FAIL -> restore the backup, no reload, report nginx -t output
```

- NEW project: there is no backup to restore. On a failed test, remove the file this
  run just created (a file this run made is the one thing it may delete) and report.
- A backup copy is verified (checksum) before the live file is replaced.
- Reload is `nginx -s reload` (or the equivalent) **after** a passing test, and its
  exit code is part of the evidence. Prefer reload over restart; a restart drops other
  projects' connections and is not part of this flow.
- After reload, the HTTP check in `deployment-workflow.md` §8 goes through the FQDN,
  so a broken proxy is caught rather than assumed fine.
