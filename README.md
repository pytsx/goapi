# Go API - User Management System

A RESTful API built with Go, following clean architecture principles for user management operations.

## 🚀 Features

- **User Management**: Complete CRUD operations for user entities
- **Clean Architecture**: Separation of concerns with controller, usecase, and repository layers
- **Database Integration**: PostgreSQL database with prepared statements
- **Dockerized**: Ready for containerized deployment
- **HTTP Framework**: Built with Gin web framework for high performance
- **Health Check**: Built-in ping endpoint for monitoring

## 🛠 Technology Stack

- **Language**: Go 1.22.5
- **Web Framework**: [Gin](https://github.com/gin-gonic/gin)
- **Database**: PostgreSQL
- **Database Driver**: [lib/pq](https://github.com/lib/pq)
- **Containerization**: Docker & Docker Compose

## 📋 Prerequisites

- Go 1.22.5 or higher
- Docker and Docker Compose
- PostgreSQL (if running without Docker)

## 🏃‍♂️ Quick Start

### Using Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/pytsx/goapi.git
   cd goapi
   ```

2. **Start the application**
   ```bash
   docker-compose up -d
   ```

3. **Verify the application is running**
   ```bash
   curl http://localhost:8080/ping
   ```

### Manual Setup

1. **Install dependencies**
   ```bash
   go mod download
   ```

2. **Set up PostgreSQL database**
   - Create a PostgreSQL database named `postgres`
   - Update connection details in `db/conn.go` if needed

3. **Create the users table**
   ```sql
   CREATE TABLE users (
       id SERIAL PRIMARY KEY,
       name VARCHAR(255) NOT NULL,
       email VARCHAR(255) NOT NULL,
       img_url VARCHAR(255)
   );
   ```

4. **Build and run**
   ```bash
   go build -o main cmd/api/main.go
   ./main
   ```

## 📚 API Documentation

### Base URL
```
http://localhost:8080
```

### Endpoints

#### Health Check
- **GET** `/ping`
- **Description**: Check if the API is running
- **Response**:
  ```json
  {
    "message": "pong"
  }
  ```

#### Get All Users
- **GET** `/users`
- **Description**: Retrieve all users
- **Response**:
  ```json
  [
    {
      "user_id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "img_url": "https://example.com/avatar.jpg"
    }
  ]
  ```

#### Get User by ID
- **GET** `/user/:id`
- **Description**: Retrieve a specific user by ID
- **Parameters**:
  - `id` (path): User ID (integer)
- **Response** (Success):
  ```json
  {
    "user_id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "img_url": "https://example.com/avatar.jpg"
  }
  ```
- **Response** (Not Found):
  ```json
  {
    "message": "Nenhum usuário foi localizado com o id fornecido"
  }
  ```

#### Create User
- **POST** `/user`
- **Description**: Create a new user
- **Request Body**:
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "img_url": "https://example.com/avatar.jpg"
  }
  ```
- **Response**:
  ```json
  {
    "user_id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "img_url": "https://example.com/avatar.jpg"
  }
  ```

### Error Responses

The API returns appropriate HTTP status codes and error messages:

- **400 Bad Request**: Invalid request data or missing required parameters
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server-side errors

## 🏗 Architecture

This project follows the **Clean Architecture** pattern with clear separation of concerns:

```
cmd/api/          # Application entry point
├── main.go       # Main application file

controller/       # HTTP layer (Gin handlers)
├── user_controller.go

usecase/          # Business logic layer
├── user_usecase.go

repository/       # Data access layer
├── user_repo.go

model/            # Domain entities
├── user.go
├── response.go

db/               # Database configuration
├── conn.go
```

### Layer Responsibilities

- **Controller**: Handles HTTP requests/responses, input validation, and routing
- **Usecase**: Contains business logic and orchestrates repository calls
- **Repository**: Manages data access and database operations
- **Model**: Defines data structures and domain entities

## 🐳 Docker Configuration

The project includes Docker configuration for easy deployment:

- **Dockerfile**: Multi-stage build for the Go application
- **docker-compose.yml**: Orchestrates the API and PostgreSQL database

### Docker Services

- **goapi**: The Go API application (port 8080)
- **godb**: PostgreSQL database (port 5432)

## 🔧 Configuration

Database connection settings are configured in `db/conn.go`:

```go
const (
    host     = "godb"        // Database host
    port     = 5432          // Database port
    user     = "postgres"    // Database user
    password = "1234"        // Database password
    dbname   = "postgres"    // Database name
)
```

## 🧪 Testing

To test the API endpoints, you can use curl, Postman, or any HTTP client:

```bash
# Health check
curl http://localhost:8080/ping

# Get all users
curl http://localhost:8080/users

# Get user by ID
curl http://localhost:8080/user/1

# Create a new user
curl -X POST http://localhost:8080/user \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "email": "jane@example.com",
    "img_url": "https://example.com/jane.jpg"
  }'
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is available under the MIT License.

## 📞 Support

If you have any questions or need help, please open an issue in the GitHub repository.