# Development Setup Guide

## Prerequisites

- Docker Desktop
- Visual Studio Code
- Dev Containers extension for VS Code

## Setup Steps

1. Clone the repository
2. Open the project in VS Code
3. When prompted, click "Reopen in Container"
4. VS Code will automatically:
   - Run setup.ps1 to create required directories
   - Build and start the development container
   - Install specified VS Code extensions
   - Set up the development environment

## Development Setup

1. Clone the repository
2. Run the setup script:

```powershell
.\setup.ps1
```

3. Open the project in VS Code
4. Reopen in Container when prompted

## Nginx

### docker-compose

```nginx:
    image: nginx:alpine
    container_name: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - development-container
    restart: unless-stopped
    networks:
      - app-network
```

### supervisord

```
[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
stdout_logfile=/var/log/nginx.log
stderr_logfile=/var/log/nginx.err.log
```

### 디렉토리 구조 생성

```powershell
# PowerShell
New-Item -ItemType Directory -Path "nginx\conf.d", "nginx\ssl" -Force
```

### Nginx 설정 파일

`기본 설정 파일을 다음 경로에 생성:`
`nginx/conf.d/default.conf`

```nginx
server {
    listen 80;
    server_name localhost;

    # Frontend
    location / {
        proxy_pass http://development-container:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://development-container:8088;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### SSL 인증서 설정

#### 인증서 생성

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx/ssl/private.key -out nginx/ssl/certificate.crt
```

### 설정 테스트

```bash
docker-compose exec nginx nginx -t
```

## Database Connection

To test the database connection from the development container:

```bash
# Make the script executable
chmod +x ./scripts/db-connect.sh

# Run the connection test
./scripts/db-connect.sh
```

Note: The database connection uses the following environment variables:

- MYSQL_USER
- MYSQL_PASSWORD
- MYSQL_DATABASE
