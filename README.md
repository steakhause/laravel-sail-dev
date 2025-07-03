# Laravel Sail Dev Stack

A fully containerized Laravel development environment using Docker and Laravel Sail.

Quick Start scripts will automatically configure all services required configured in .env file.
* Laravel App and Domain
* Database type and credentials
* Local dns entries in Nginx Proxy Manager and Pi-Hole for local ssl
* Mail service

Fish Shell and Tree included.

## 🚀 Quick Start (with Docker Compose)

### Copy the .env.example
```bash
cp .env.example .env

### Configure the environment variables in .env

Run from the project\'s root dir
Setting 

```bash
./quick-start/full_configuration.sh
