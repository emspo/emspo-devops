*** UPDATE DOCKER DAEMON FILE AS BELOW ***

# Prometheus Monitoring for Docker

This directory contains configuration and setup for running Prometheus to monitor Docker services.

## Features
- Prometheus monitoring for Docker metrics
- Example configuration for scraping Docker Engine metrics
- Easy integration with Docker Compose

## Setup Instructions

### 1. Enable Docker Metrics Endpoint

Edit or create the Docker daemon config file at `/etc/docker/daemon.json` (Linux) or `C:\\ProgramData\\docker\\config\\daemon.json` (Windows):

```
{
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}
```

Restart Docker after saving the file:

```
sudo systemctl restart docker  # Linux
```

### 2. Configure Prometheus

Edit `prometheus.yml` and add a scrape job for Docker:

```
scrape_configs:
  # ...existing configs...
  - job_name: 'docker'
    static_configs:
      - targets: ['host.docker.internal:9323']
```

- Use `host.docker.internal:9323` for Windows/Mac, or your host IP for Linux.

### 3. Start Prometheus

From this directory, run:

```
docker compose up -d
```

Prometheus will be available at [http://localhost:9090](http://localhost:9090).

### 4. Verify Docker Metrics

- Open Prometheus web UI: [http://localhost:9090](http://localhost:9090)
- Go to **Status > Targets** and check that the Docker job is listed and "UP".
- Query Docker metrics (e.g., `engine_daemon_engine_info`) in the **Graph** tab.

## Troubleshooting
- Ensure Docker metrics endpoint is enabled and accessible.
- Check firewall or network settings if Prometheus cannot reach the Docker endpoint.
- Review Docker and Prometheus logs for errors.

## References
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [Docker Metrics](https://docs.docker.com/config/daemon/prometheus/)