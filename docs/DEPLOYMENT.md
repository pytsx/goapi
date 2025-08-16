# Deployment Guide

## Overview

This guide provides comprehensive instructions for deploying the Go API in various environments, from local development to production.

## Prerequisites

- Docker 20.10+
- Docker Compose 1.28+
- Go 1.22.5+ (for local development)
- PostgreSQL 13+ (if not using Docker)

## Deployment Options

### 1. Docker Compose Deployment (Recommended)

This is the easiest way to deploy the entire stack.

#### Quick Deployment

```bash
# Clone the repository
git clone https://github.com/pytsx/goapi.git
cd goapi

# Start the application stack
docker-compose up -d

# Verify deployment
curl http://localhost:8080/ping
```

#### Configuration

The `docker-compose.yml` defines two services:

```yaml
services:
  goapi:
    container_name: goapi
    image: github.com/pytsx/goapi
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - godb
      
  godb:
    container_name: godb
    image: postgres:latest
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: 1234
      POSTGRES_DB: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
```

#### Customization

Create a `.env` file for environment-specific values:

```bash
# .env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=goapi
API_PORT=8080
DB_HOST=godb
DB_PORT=5432
```

Update `docker-compose.yml` to use environment variables:

```yaml
services:
  goapi:
    container_name: goapi
    build: .
    ports:
      - "${API_PORT:-8080}:8080"
    environment:
      - DB_HOST=${DB_HOST:-godb}
      - DB_PORT=${DB_PORT:-5432}
      - DB_USER=${POSTGRES_USER:-postgres}
      - DB_PASSWORD=${POSTGRES_PASSWORD:-1234}
      - DB_NAME=${POSTGRES_DB:-postgres}
    depends_on:
      - godb
      
  godb:
    container_name: godb
    image: postgres:latest
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-1234}
      POSTGRES_DB: ${POSTGRES_DB:-postgres}
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
```

### 2. Local Development Deployment

For development without Docker:

#### Database Setup

```bash
# Install PostgreSQL (Ubuntu/Debian)
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database and user
sudo -u postgres psql
CREATE DATABASE goapi;
CREATE USER goapi_user WITH ENCRYPTED PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE goapi TO goapi_user;
\q
```

#### Create Database Schema

```sql
-- Connect to the database
psql -U goapi_user -d goapi -h localhost

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    img_url VARCHAR(255)
);

-- Verify table creation
\dt
\q
```

#### Application Setup

```bash
# Install dependencies
go mod download

# Update database connection in db/conn.go
# Or use environment variables (recommended)

# Build and run
go build -o goapi cmd/api/main.go
./goapi
```

### 3. Production Deployment

#### Using Docker Swarm

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml goapi-stack

# Check services
docker stack services goapi-stack

# Scale the API service
docker service scale goapi-stack_goapi=3
```

#### Using Kubernetes

Create Kubernetes manifests:

**namespace.yaml**:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: goapi
```

**postgres-deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: goapi
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:latest
        env:
        - name: POSTGRES_DB
          value: "postgres"
        - name: POSTGRES_USER
          value: "postgres"
        - name: POSTGRES_PASSWORD
          value: "1234"
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
```

**goapi-deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: goapi
  namespace: goapi
spec:
  replicas: 3
  selector:
    matchLabels:
      app: goapi
  template:
    metadata:
      labels:
        app: goapi
    spec:
      containers:
      - name: goapi
        image: github.com/pytsx/goapi:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          value: "postgres-service"
```

Deploy to Kubernetes:
```bash
kubectl apply -f namespace.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f goapi-deployment.yaml
kubectl apply -f services.yaml
```

## Environment Variables

For production deployments, use environment variables instead of hardcoded values:

```go
// db/conn.go (recommended modification)
package db

import (
    "database/sql"
    "fmt"
    "os"
    
    _ "github.com/lib/pq"
)

func ConnectDB() (*sql.DB, error) {
    host := getEnv("DB_HOST", "localhost")
    port := getEnv("DB_PORT", "5432")
    user := getEnv("DB_USER", "postgres")
    password := getEnv("DB_PASSWORD", "1234")
    dbname := getEnv("DB_NAME", "postgres")
    
    psqlInfo := fmt.Sprintf("host=%s port=%s user=%s "+
        "password=%s dbname=%s sslmode=disable",
        host, port, user, password, dbname)
    
    db, err := sql.Open("postgres", psqlInfo)
    if err != nil {
        return nil, err
    }
    
    err = db.Ping()
    if err != nil {
        return nil, err
    }
    
    return db, nil
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}
```

## Health Checks

### Application Health Check

The API includes a basic health check endpoint:

```bash
curl http://localhost:8080/ping
```

### Database Health Check

Add a database health check endpoint:

```go
// Add to controller/user_controller.go
func (uc *UserController) HealthCheck(ctx *gin.Context) {
    // Test database connection
    err := uc.userUsecase.HealthCheck()
    if err != nil {
        ctx.JSON(http.StatusServiceUnavailable, gin.H{
            "status": "unhealthy",
            "database": "disconnected"
        })
        return
    }
    
    ctx.JSON(http.StatusOK, gin.H{
        "status": "healthy",
        "database": "connected"
    })
}
```

### Docker Health Check

Add to Dockerfile:

```dockerfile
FROM golang:1.22.5

WORKDIR /go/src/app
COPY . .

EXPOSE 8080

RUN go build -o main cmd/api/main.go

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ping || exit 1

CMD ["./main"]
```

## Monitoring and Logging

### Basic Logging

Add structured logging:

```go
// Add to main.go
import "log"

func main() {
    // ... existing code
    
    log.Println("Starting server on port 8080")
    server.Run(":8080")
}
```

### Request Logging Middleware

```go
// Add to main.go
import "github.com/gin-gonic/gin"

func main() {
    server := gin.Default()
    
    // Add logging middleware
    server.Use(gin.Logger())
    server.Use(gin.Recovery())
    
    // ... rest of setup
}
```

## Security Considerations

### Production Security

1. **Remove Debug Mode**:
   ```go
   gin.SetMode(gin.ReleaseMode)
   ```

2. **Use HTTPS**: Configure TLS certificates

3. **Environment Variables**: Never hardcode sensitive data

4. **Database Security**: Use connection pooling and prepared statements

5. **CORS Configuration**: Add proper CORS headers if needed

### Dockerfile Security

```dockerfile
# Use non-root user
FROM golang:1.22.5-alpine AS builder

WORKDIR /app
COPY . .
RUN go build -o main cmd/api/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

# Create non-root user
RUN adduser -D -s /bin/sh apiuser
USER apiuser

COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
```

## Backup and Recovery

### Database Backup

```bash
# Create backup
docker exec godb pg_dump -U postgres postgres > backup.sql

# Restore backup
docker exec -i godb psql -U postgres postgres < backup.sql
```

### Automated Backups

Create a backup script:

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
CONTAINER_NAME="godb"

mkdir -p $BACKUP_DIR

docker exec $CONTAINER_NAME pg_dump -U postgres postgres > $BACKUP_DIR/backup_$DATE.sql

# Keep only last 7 days of backups
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete

echo "Backup completed: backup_$DATE.sql"
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**:
   ```bash
   # Check if database is running
   docker ps
   
   # Check database logs
   docker logs godb
   
   # Test connection
   docker exec -it godb psql -U postgres
   ```

2. **Port Already in Use**:
   ```bash
   # Find process using port 8080
   lsof -i :8080
   
   # Kill process
   kill -9 <PID>
   ```

3. **Container Build Issues**:
   ```bash
   # Clear Docker cache
   docker system prune -a
   
   # Rebuild without cache
   docker-compose build --no-cache
   ```

### Debug Mode

Enable debug logging:

```bash
# Set Gin to debug mode
export GIN_MODE=debug

# Run with verbose output
docker-compose up
```

## Performance Optimization

### Database Optimization

1. **Connection Pooling**: Configure connection limits
2. **Indexes**: Add indexes for frequently queried columns
3. **Query Optimization**: Use EXPLAIN to analyze queries

### Application Optimization

1. **Build Optimization**: Use multi-stage Docker builds
2. **Resource Limits**: Set memory and CPU limits
3. **Caching**: Implement Redis for caching if needed

This deployment guide provides a comprehensive approach to deploying the Go API in various environments while maintaining security and performance best practices.