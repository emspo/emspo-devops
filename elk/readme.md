
# ELK Stack Deployment

This directory contains configuration and deployment files for running the **ELK Stack** (Elasticsearch, Logstash, Kibana) using Docker Compose.

## Overview

The ELK stack is a powerful set of tools for searching, analyzing, and visualizing log data in real time. This setup is intended for local development, testing, or as a starting point for production deployments.

## Directory Structure

- `docker-compose.yml` — Main Docker Compose file to launch the ELK stack
- `elasticsearch/` — Elasticsearch configuration and data
- `kibana/` — Kibana configuration
- `logstash/` — Logstash configuration and pipelines

## Prerequisites

- [Docker](https://www.docker.com/get-started) and [Docker Compose](https://docs.docker.com/compose/) installed
- At least 4GB RAM available for Docker

## Usage

1. **Start the ELK stack:**
	 ```sh
	 docker compose up -d
	 ```

2. **Access the services:**
	 - **Kibana:** http://localhost:5601
	 - **Elasticsearch:** http://localhost:9200
	 - **Logstash:** Listens on ports as defined in `logstash/pipeline/` configs

3. **Stop the stack:**
	 ```sh
	 docker compose down
	 ```

## Customization

- **Elasticsearch:**
	- Data is persisted in `elasticsearch/data/`
	- Configurations can be changed in `elasticsearch/`
- **Kibana:**
	- Settings are in `kibana/kibana.yml`
- **Logstash:**
	- Pipelines and settings are in `logstash/pipeline/` and `logstash/settings/`

## Troubleshooting

- Check container logs:
	```sh
	docker compose logs elasticsearch
	docker compose logs kibana
	docker compose logs logstash
	```
- Ensure ports 9200 (Elasticsearch) and 5601 (Kibana) are not in use by other processes.


## Resetting Elasticsearch Password

If you need to reset the `elastic` user password in your Elasticsearch Docker container:

1. Find the running Elasticsearch container name or ID:
	```powershell
	docker ps
	```

2. Run the password reset command inside the container (replace `<container_name>` with your actual container name or ID):
	```powershell
	docker exec -it <container_name> bin/elasticsearch-reset-password -u elastic
	```
	This will prompt you to enter a new password or generate one for you.

3. Use the new password to log in with the `elastic` user.


## Resetting kibana_system User Password for Kibana

If Kibana fails to connect to Elasticsearch due to authentication errors, you may need to reset the `kibana_system` user password:

1. Find your Elasticsearch container name or ID:
	```powershell
	docker ps
	```

2. Run the password reset command for `kibana_system` inside the container (replace `<container_name>` with your actual container name or ID):
	```powershell
	docker exec -it <container_name> bin/elasticsearch-reset-password -u kibana_system
	```
	This will prompt you to enter a new password or generate one.

3. Update your `kibana/kibana.yml` file:
	- Set `elasticsearch.username` to `"kibana_system"`
	- Set `elasticsearch.password` to the new password you just set

4. Restart Kibana:
	```powershell
	docker compose restart kibana
	```

This ensures Kibana can authenticate with Elasticsearch using the correct credentials.

---

## References

- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Logstash Documentation](https://www.elastic.co/guide/en/logstash/current/index.html)
