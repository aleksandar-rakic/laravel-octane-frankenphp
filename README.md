# Laravel Octane + FrankenPHP

> Production-ready Laravel 11 setup with FrankenPHP, PostgreSQL, Redis, and full CI/CD pipeline.

[![CI](https://github.com/aleksandar-rakic/laravel-octane-frankenphp/actions/workflows/ci.yml/badge.svg)](https://github.com/aleksandar-rakic/laravel-octane-frankenphp/actions/workflows/ci.yml)
[![PHP](https://img.shields.io/badge/PHP-8.3-777BB4?style=flat-square&logo=php&logoColor=white)](https://php.net)
[![Laravel](https://img.shields.io/badge/Laravel-11-FF2D20?style=flat-square&logo=laravel&logoColor=white)](https://laravel.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

## Why FrankenPHP over PHP-FPM?

| | PHP-FPM | FrankenPHP + Octane |
|---|---|---|
| Request handling | Process per request | Persistent workers |
| Boot time | Every request | Once at startup |
| Throughput | ~800 req/s | ~4,000+ req/s |
| Memory | Reloaded each request | Shared across requests |
| HTTP/2 & HTTP/3 | Via separate proxy | Built-in |
| TLS | Via NGINX | Built-in (Caddy) |

## Stack

- **Runtime** — [FrankenPHP](https://frankenphp.dev) (Go-powered PHP server, HTTP/2 & HTTP/3, built-in TLS)
- **Framework** — Laravel 11 + [Octane](https://laravel.com/docs/octane)
- **Database** — PostgreSQL 16
- **Cache / Queue** — Redis 7
- **Code quality** — [Pint](https://laravel.com/docs/pint) + [PHPStan](https://phpstan.org) (level 8) + [Larastan](https://github.com/larastan/larastan)
- **CI/CD** — GitHub Actions (lint → test → Docker build → deploy)
- **Container registry** — GitHub Container Registry (GHCR)

## Getting Started

```bash
# Clone
git clone https://github.com/aleksandar-rakic/laravel-octane-frankenphp.git
cd laravel-octane-frankenphp

# Environment
cp .env.example .env

# Start
docker compose up -d

# Generate key & migrate
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate
```

App is available at **http://localhost**

## Services

| Service | Description | Port |
|---------|-------------|------|
| `app` | Laravel + FrankenPHP (HTTP/2) | 80, 443 |
| `db` | PostgreSQL 16 | 5432 |
| `redis` | Redis 7 | 6379 |
| `queue` | Laravel Queue Worker | — |
| `scheduler` | Laravel Scheduler | — |

## Health Check

```bash
curl http://localhost/up
```

```json
{
  "status": "healthy",
  "timestamp": "2026-06-04T14:00:00+00:00",
  "checks": {
    "database": true,
    "cache": true,
    "octane": true
  }
}
```

## CI/CD Pipeline

```
push to main
    │
    ├── lint        Laravel Pint + PHPStan level 8
    ├── test        PHPUnit parallel + PostgreSQL + Redis
    ├── docker      Build → GHCR (ghcr.io/aleksandar-rakic/laravel-octane-frankenphp)
    └── deploy      SSH → docker compose pull → migrate → octane:reload
```

## Production Deployment

Set these secrets in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `SSH_HOST` | Production server IP/hostname |
| `SSH_USER` | SSH username |
| `SSH_PRIVATE_KEY` | Private SSH key |

## Code Quality

```bash
# Code style
docker compose exec app ./vendor/bin/pint

# Static analysis
docker compose exec app ./vendor/bin/phpstan analyse

# Tests
docker compose exec app php artisan test --parallel
```

## License

MIT © [Aleksandar Rakić](https://github.com/aleksandar-rakic)
