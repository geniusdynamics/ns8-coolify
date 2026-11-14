# NS8 Coolify Module

[![NethServer 8](https://img.shields.io/badge/NethServer-8-blue)](https://github.com/geniusdynamics/gcns8-core)
[![License](https://img.shields.io/badge/License-GPL--3.0-green)](LICENSE)

A [NethServer 8](https://github.com/geniusdynamics/gcns8-core) module that integrates **Coolify** - an open-source, self-hosted alternative to Heroku/Netlify for deploying web applications.

## What is Coolify?

[Coolify](https://coolify.io) is a self-hosted platform that allows you to deploy web applications (static sites, Node.js, PHP, Python, etc.) with automatic HTTPS, database provisioning, and more. It provides:

- **One-click deployments** from Git repositories
- **Automatic HTTPS certificates** via Let's Encrypt
- **Database management** (PostgreSQL, MySQL, MongoDB, Redis)
- **Docker container orchestration**
- **Webhook integrations** for CI/CD
- **Team collaboration features**

This module brings Coolify's powerful deployment capabilities to your NethServer infrastructure.

## Features

- 🚀 Easy deployment of web applications
- 🔒 Integrated with NethServer's security model
- 🌐 Automatic domain configuration with Traefik
- 📊 Web-based management interface
- 🔄 Automated updates and rollbacks
- 🗄️ Database provisioning and management
- 📱 Mobile-friendly UI

## Installation

### Prerequisites

- NethServer 8 cluster
- At least 2GB RAM available
- Docker/Podman support

### Install the Module

Instantiate the module with:

```bash
add-module ghcr.io/geniusdynamics/coolify:latest 1
```

The output will return the instance name:

```json
{
  "module_id": "coolify1",
  "image_name": "coolify",
  "image_url": "ghcr.io/geniusdynamics/coolify:latest"
}
```

## Coolify version

The module runs **Coolify 4.7.5** (`ghcr.io/coollabsio/coolify:4.7.5`) with
PostgreSQL 15 (`docker.io/postgres:15.20-alpine3.24`) and Redis 7
(`docker.io/redis:7.4.12-alpine3.22`). Module 1.8.0 and older ran Coolify 4.0.1.

### Changes since Coolify 4.0.1 that affect the module

- **The realtime container is gone.** Since Coolify 4.4 the realtime server
  (Laravel Reverb, port 6001) and the terminal server (port 6002) run inside
  the Coolify container, and its nginx proxies them on the dashboard host name
  (`/app/` and `/terminal/ws`). The module no longer runs `soketi-app` or pulls
  `ghcr.io/coollabsio/coolify-realtime`.
- **The realtime keys must match.** Reverb checks the `PUSHER_APP_*` keys,
  which module 1.8.0 left empty. The module now generates them.
- **New storage for avatars and project icons**, in the `coolify-images` volume.
- **SSH host key pinning** (Coolify 4.7): the new `ssh_host_key_checking`
  setting picks the mode.
- **Root account window:** a new Coolify accepts the first (root) account
  registration only for **10 minutes after Coolify starts**. If the window
  closed before you registered, restart the module services
  (`runagent -m coolify1 systemctl --user restart coolify-app.service`) and
  register within 10 minutes.
- PostgreSQL and Redis keep their major versions (upstream still uses
  `postgres:15` and `redis:7`), so the update needs no database dump and restore.

### What the update from 1.8.0 does

The `update-module.d/10migrate_coolify_4_7` step runs before the restart and:

1. stops and removes the legacy `soketi-app` container, its unit and its image;
2. keeps every existing secret (`APP_KEY`, database password) and generates the
   missing ones once: a Redis password (Redis now requires it) and the realtime
   app keys. All of them are in `state/*.env` files with mode 0600;
3. converts the settings: the containers reach PostgreSQL and Redis on
   `127.0.0.1` instead of container names, `APP_URL` gets its `https://`
   scheme, `PHP_PM_*` become the `PHP_FPM_PM_*` names that the image reads
   (custom values are kept), and `AUTOUPDATE` is turned off because
   NethServer updates the module;
4. then `20restart` restarts the pod, PostgreSQL, Redis and Coolify. Coolify
   runs its database migrations from 4.0.1 to 4.7.5 when it starts: the first
   start can take a few minutes.

Admins have nothing to do. The `socket.<host>` and `websocket.<host>` routes
stay for compatibility, but Coolify 4.7.5 no longer needs them: the browser uses
the dashboard host name for everything.

### Backup and restore

Backups now include the PostgreSQL dump (`state/coolify.pg_dump`) and the
`coolify-images` volume. **Backups made by module 1.8.0 or older contain no
database**, because their include list did not have the dump. Restoring one
now works (before, the restore failed). It brings back the settings, secrets
and Coolify volumes, but Coolify starts with an empty database. Take a new
backup after the update. Restore and clone never turn on Let's Encrypt: enable
it again once the DNS points to the new node.

## Configuration

Launch `configure-module` with the following parameters:

- `host`: Fully qualified domain name for Coolify
- `http2https`: Enable/disable HTTP to HTTPS redirection (`true`/`false`)
- `lets_encrypt`: Enable/disable Let's Encrypt certificate (`true`/`false`)
- `ssh_host_key_checking` (optional, default `warn`): what Coolify does when
  the SSH host key of a server changes. `warn` connects and notifies the team,
  `enforce` refuses the connection, and `off` disables the check. The UI shows it
  under Settings > Advanced.

### Example Configuration

```bash
api-cli run configure-module --agent module/coolify1 --data - <<EOF
{
  "host": "coolify.yourdomain.com",
  "http2https": true,
  "lets_encrypt": true,
  "ssh_host_key_checking": "warn"
}
EOF
```

This will:

- Start and configure the Coolify instance
- Set up a virtual host in Traefik for external access
- Configure automatic HTTPS if enabled

## Usage

1. **Access Coolify**: Navigate to `https://coolify.yourdomain.com`
2. **Initial Setup**: Register your admin account within 10 minutes of the first start (see above)
3. **Deploy Applications**: Connect your Git repositories and deploy
4. **Manage Resources**: Use the web interface to monitor and manage your deployments

## Module Management

### Get Configuration

```bash
api-cli run get-configuration --agent module/coolify1
```

### Update Module

```bash
api-cli run update-module --data '{"module_url":"ghcr.io/geniusdynamics/coolify:latest","instances":["coolify1"],"force":true}'
```

### Uninstall

```bash
remove-module --no-preserve coolify1
```

## Advanced Configuration

### Smarthost Integration

The module automatically discovers and integrates with NethServer's centralized [smarthost setup](https://nethserver.github.io/ns8-core/core/smarthost/). When the smarthost configuration changes, the module automatically reloads its services.

### Environment Variables

The module runs with comprehensive environment variables managed by the NethServer agent. Key variables include database connection details, service ports, and security settings.

## Development & Debugging

### Debug Commands

Check environment variables:

```bash
runagent -m coolify1 env
```

Enter the module's runtime environment:

```bash
runagent -m coolify1
```

Inspect running containers:

```bash
runagent -m coolify1
podman ps
```

Access container environment:

```bash
podman exec coolify-app env
```

Open shell in container:

```bash
podman exec -ti coolify-app sh
```

### UI Development

The module includes a Vue.js-based web interface. For UI development:

1. Navigate to the `ui/` directory
2. Follow the [NethServer UI development guide](https://nethserver.github.io/ns8-core/ui/modules/#module-ui-development)

## Testing

Test the module using the provided script:

```bash
./test-module.sh <NODE_ADDR> ghcr.io/geniusdynamics/gccoolify:latest
```

Tests are written using [Robot Framework](https://robotframework.org/).

## Translation

The UI supports multiple languages and is translated via [Weblate](https://hosted.weblate.org/projects/ns8/).

To contribute translations:

- Add the [GitHub Weblate app](https://docs.weblate.org/en/latest/admin/continuous.html#github-setup) to your repository
- Add your repository to [hosted.weblate.org](https://hosted.weblate.org) or request addition to the NS8 Weblate project

## Support & Contributing

- 📖 [NethServer Documentation](https://nethserver.github.io/ns8-core/)
- 🐛 [Report Issues](https://github.com/geniusdynamics/gcns8-coolify/issues)
- 💬 [Community Forum](https://community.nethserver.org/)
- 🤝 [Contributing Guide](CONTRIBUTING.md)

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.
