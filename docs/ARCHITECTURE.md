# Architecture Documentation

## Overview

This Go API follows the **Clean Architecture** pattern, which promotes separation of concerns and maintainability by organizing code into distinct layers with clear dependencies.

## Clean Architecture Principles

The architecture follows these key principles:

1. **Independence of Frameworks**: The architecture doesn't depend on external frameworks
2. **Testability**: Business rules can be tested independently
3. **Independence of UI**: The UI can change without affecting the system
4. **Independence of Database**: The database can be swapped without affecting business rules
5. **Independence of External Services**: Business rules don't know about external services

## Layer Structure

```
┌─────────────────────────────────────────────────────┐
│                    Presentation Layer                │
│                  (controller/)                      │
├─────────────────────────────────────────────────────┤
│                     Business Layer                   │
│                    (usecase/)                       │
├─────────────────────────────────────────────────────┤
│                   Data Access Layer                  │
│                   (repository/)                     │
├─────────────────────────────────────────────────────┤
│                     Database Layer                   │
│                     (PostgreSQL)                    │
└─────────────────────────────────────────────────────┘
```

## Directory Structure

```
goapi/
├── cmd/api/              # Application entry point
│   └── main.go          # Main application file
├── controller/          # Presentation layer
│   └── user_controller.go
├── usecase/            # Business logic layer
│   └── user_usecase.go
├── repository/         # Data access layer
│   └── user_repo.go
├── model/              # Domain entities
│   ├── user.go
│   └── response.go
├── db/                 # Database configuration
│   └── conn.go
├── docker-compose.yml  # Container orchestration
├── Dockerfile          # Container definition
├── go.mod             # Go module definition
└── go.sum             # Go module checksums
```

## Layer Responsibilities

### 1. Presentation Layer (`controller/`)

**Purpose**: Handles HTTP requests and responses

**Responsibilities**:
- HTTP request parsing
- Input validation
- Response formatting
- HTTP status code management
- Routing logic

**Key Components**:
- `UserController`: Handles user-related HTTP endpoints

**Dependencies**: 
- Uses `usecase` layer for business logic
- Uses `model` package for data structures

**Example**:
```go
func (uc *UserController) CreateUser(ctx *gin.Context) {
    var user model.User
    err := ctx.BindJSON(&user)
    if err != nil {
        ctx.JSON(http.StatusBadRequest, err)
        return
    }
    
    insertedUser, err := uc.userUsecase.CreateUser(user)
    // ... error handling and response
}
```

### 2. Business Logic Layer (`usecase/`)

**Purpose**: Contains business rules and orchestrates data flow

**Responsibilities**:
- Business logic implementation
- Data transformation
- Orchestrating repository calls
- Business rule validation

**Key Components**:
- `UserUsecase`: Implements user-related business logic

**Dependencies**:
- Uses `repository` layer for data access
- Uses `model` package for data structures

**Example**:
```go
func (uu *UserUsecase) CreateUser(user model.User) (model.User, error) {
    uid, err := uu.repository.CreateUser(user)
    if err != nil {
        return model.User{}, err
    }
    
    user.ID = uid
    return user, nil
}
```

### 3. Data Access Layer (`repository/`)

**Purpose**: Manages data persistence and retrieval

**Responsibilities**:
- Database operations (CRUD)
- Query construction
- Data mapping
- Connection management

**Key Components**:
- `UserRepository`: Handles user data persistence

**Dependencies**:
- Uses `model` package for data structures
- Direct database connection

**Example**:
```go
func (ur *UserRepository) CreateUser(user model.User) (int, error) {
    query, err := ur.connection.Prepare("INSERT INTO user ...")
    if err != nil {
        return -1, err
    }
    
    err = query.QueryRow(user.Name, user.Email, user.ImgURL).Scan(&id)
    // ... error handling
    return id, nil
}
```

### 4. Domain Models (`model/`)

**Purpose**: Defines core data structures

**Responsibilities**:
- Data structure definitions
- JSON serialization tags
- Domain entity representation

**Key Components**:
- `User`: Core user entity
- `Response`: Standard response structure

## Data Flow

### Request Flow (Create User Example)

```
1. HTTP POST /user
   ↓
2. UserController.CreateUser()
   ├── Parses JSON request
   ├── Validates input format
   ↓
3. UserUsecase.CreateUser()
   ├── Applies business rules
   ├── Prepares data for storage
   ↓
4. UserRepository.CreateUser()
   ├── Executes SQL INSERT
   ├── Returns generated ID
   ↓
5. Response flows back up the layers
   ├── Usecase adds ID to user object
   ├── Controller formats HTTP response
   ↓
6. HTTP 201 Created with user data
```

### Response Flow

```
Database → Repository → Usecase → Controller → HTTP Response
```

## Dependency Injection

The application uses constructor injection to manage dependencies:

```go
// main.go
dbConnection, err := db.ConnectDB()
userRepo := repository.NewUserRepository(dbConnection)
userUsecase := usecase.NewUserUsecase(userRepo)
userController := controller.NewUserController(userUsecase)
```

This pattern ensures:
- Loose coupling between layers
- Easy testing with mock dependencies
- Clear dependency relationships

## Error Handling Strategy

### Layer-Specific Error Handling

1. **Controller Layer**:
   - Handles HTTP-specific errors
   - Converts internal errors to appropriate HTTP status codes
   - Formats error responses

2. **Usecase Layer**:
   - Handles business logic errors
   - Validates business rules
   - Propagates repository errors

3. **Repository Layer**:
   - Handles database errors
   - Connection issues
   - Query execution errors

### Error Flow

```
Repository Error → Usecase → Controller → HTTP Error Response
```

## Testing Strategy

The clean architecture enables easy testing:

### Unit Testing
- **Controllers**: Mock usecase dependencies
- **Usecases**: Mock repository dependencies  
- **Repositories**: Use test databases or mocks

### Integration Testing
- Test complete request flows
- Use test database containers
- Validate API contracts

## Benefits of This Architecture

1. **Maintainability**: Clear separation of concerns
2. **Testability**: Easy to mock dependencies
3. **Flexibility**: Can swap implementations easily
4. **Scalability**: Easy to add new features
5. **Independence**: Layers don't depend on implementation details

## Future Enhancements

Potential architectural improvements:

1. **Add Interfaces**: Define interfaces for better abstraction
2. **Middleware**: Add authentication, logging, rate limiting
3. **Validation Layer**: Dedicated input validation
4. **Service Layer**: Additional business logic abstraction
5. **Error Handling**: Centralized error handling
6. **Configuration**: External configuration management

## Database Schema

Current database structure:

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    img_url VARCHAR(255)
);
```

## Configuration Management

Database configuration is currently hardcoded in `db/conn.go`:

```go
const (
    host     = "godb"
    port     = 5432
    user     = "postgres"
    password = "1234"
    dbname   = "postgres"
)
```

**Recommendation**: Move to environment variables for production deployment.