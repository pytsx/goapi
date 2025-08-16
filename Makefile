# Makefile for Go API project

.PHONY: help build run test clean docker-up docker-down docker-rebuild setup-db test-api lint fmt vet

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Development commands
build: ## Build the Go application
	go build -o bin/goapi cmd/api/main.go

run: ## Run the application locally
	go run cmd/api/main.go

test: ## Run all tests
	go test -v ./...

test-coverage: ## Run tests with coverage
	go test -cover ./...
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

clean: ## Clean build artifacts
	rm -f bin/goapi
	rm -f coverage.out coverage.html
	go clean ./...

# Docker commands
docker-up: ## Start the application with Docker Compose
	docker-compose up -d

docker-down: ## Stop the Docker Compose stack
	docker-compose down

docker-rebuild: ## Rebuild and restart Docker containers
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d

docker-logs: ## Show Docker container logs
	docker-compose logs -f

# Database commands
setup-db: ## Set up the database schema
	docker exec -i godb psql -U postgres -d postgres < scripts/setup-database.sql

reset-db: ## Reset the database (WARNING: This will delete all data)
	docker-compose down -v
	docker-compose up -d
	sleep 5
	make setup-db

# Testing commands
test-api: ## Run API integration tests
	@echo "Starting API tests..."
	@if ! curl -s http://localhost:8080/ping >/dev/null 2>&1; then \
		echo "API is not running. Starting with Docker Compose..."; \
		make docker-up; \
		sleep 10; \
	fi
	./scripts/test-api.sh

# Code quality commands
lint: ## Run linter
	golangci-lint run

fmt: ## Format Go code
	go fmt ./...
	goimports -w .

vet: ## Run go vet
	go vet ./...

# Development setup
dev-setup: ## Set up development environment
	go mod download
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install golang.org/x/tools/cmd/goimports@latest

# All quality checks
check: fmt vet lint test ## Run all code quality checks

# Install dependencies
deps: ## Download Go module dependencies
	go mod download
	go mod tidy

# Create directories
dirs: ## Create necessary directories
	mkdir -p bin
	mkdir -p logs

# Database backup
backup-db: ## Create database backup
	docker exec godb pg_dump -U postgres postgres > backup-$(shell date +%Y%m%d_%H%M%S).sql

# Show project info
info: ## Show project information
	@echo "Go API Project Information"
	@echo "=========================="
	@echo "Go version: $(shell go version)"
	@echo "Project path: $(shell pwd)"
	@echo "Docker status: $(shell docker-compose ps --services --filter status=running | wc -l) services running"
	@echo "Git branch: $(shell git branch --show-current 2>/dev/null || echo 'not in git repo')"
	@echo "Git status: $(shell git status --porcelain | wc -l) uncommitted files"

# Quick start
quick-start: docker-up setup-db test-api ## Quick start: build, run, and test everything

# Production build
prod-build: ## Build for production
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bin/goapi cmd/api/main.go