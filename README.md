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

## Configuration

Launch `configure-module` with the following parameters:

- `host`: Fully qualified domain name for Coolify
- `http2https`: Enable/disable HTTP to HTTPS redirection (`true`/`false`)
- `lets_encrypt`: Enable/disable Let's Encrypt certificate (`true`/`false`)

### Example Configuration

```bash
api-cli run configure-module --agent module/coolify1 --data - <<EOF
{
  "host": "coolify.yourdomain.com",
  "http2https": true,
  "lets_encrypt": true
}
EOF
```

This will:

- Start and configure the Coolify instance
- Set up a virtual host in Traefik for external access
- Configure automatic HTTPS if enabled

## Usage

1. **Access Coolify**: Navigate to `https://coolify.yourdomain.com`
2. **Initial Setup**: Register your admin account
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
