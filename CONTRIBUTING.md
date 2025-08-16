# Contributing Guide

## Welcome Contributors! 👋

Thank you for your interest in contributing to the Go API project! This guide will help you get started with contributing to our codebase.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)
- [Release Process](#release-process)

## Code of Conduct

### Our Pledge

We are committed to making participation in this project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment include:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- Go 1.22.5 or higher
- Docker and Docker Compose
- Git
- A code editor (VS Code, GoLand, etc.)

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/goapi.git
   cd goapi
   ```
3. **Add the upstream repository**:
   ```bash
   git remote add upstream https://github.com/pytsx/goapi.git
   ```

## Development Setup

### Environment Setup

1. **Install Go dependencies**:
   ```bash
   go mod download
   ```

2. **Start the development environment**:
   ```bash
   docker-compose up -d
   ```

3. **Verify the setup**:
   ```bash
   curl http://localhost:8080/ping
   ```

### Database Setup

The development database is automatically created with Docker Compose. If you need to reset it:

```bash
docker-compose down -v
docker-compose up -d
```

### IDE Configuration

#### VS Code

Recommended extensions:
- Go (by Google)
- Docker
- PostgreSQL
- REST Client

Create `.vscode/settings.json`:
```json
{
    "go.useLanguageServer": true,
    "go.lintTool": "golangci-lint",
    "go.formatTool": "goimports",
    "go.testFlags": ["-v"],
    "files.eol": "\n"
}
```

#### GoLand

- Enable Go modules support
- Set GOROOT to your Go installation
- Configure code style to use gofmt

## Making Changes

### Branching Strategy

We use a feature branch workflow:

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our coding standards

3. **Test your changes** thoroughly

4. **Commit your changes** with clear commit messages

### Commit Message Guidelines

Follow conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(user): add email validation to user creation
fix(api): handle database connection errors properly
docs(readme): update installation instructions
test(user): add unit tests for user controller
```

## Coding Standards

### Go Style Guide

Follow the official [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments) and [Effective Go](https://golang.org/doc/effective_go.html).

#### Key Principles

1. **Use gofmt** for formatting
2. **Use golint** for style checking
3. **Use go vet** for detecting suspicious code
4. **Follow Go naming conventions**

#### Naming Conventions

```go
// Good
type UserController struct {
    userUsecase usecase.UserUsecase
}

func (uc *UserController) CreateUser(ctx *gin.Context) {
    // implementation
}

// Variables and functions
var maxRetries = 3
func getUserByID(id int) (*User, error) {
    // implementation
}

// Constants
const (
    MaxUsernameLength = 255
    DefaultTimeout    = 30 * time.Second
)
```

#### Error Handling

```go
// Good - Wrap errors with context
func (ur *UserRepository) CreateUser(user model.User) (int, error) {
    query, err := ur.connection.Prepare("INSERT INTO users...")
    if err != nil {
        return -1, fmt.Errorf("failed to prepare user creation query: %w", err)
    }
    defer query.Close()
    
    var id int
    err = query.QueryRow(user.Name, user.Email, user.ImgURL).Scan(&id)
    if err != nil {
        return -1, fmt.Errorf("failed to create user: %w", err)
    }
    
    return id, nil
}
```

#### Package Structure

Follow the established clean architecture pattern:

```
controller/     # HTTP handlers
usecase/        # Business logic
repository/     # Data access
model/          # Domain entities
db/             # Database configuration
```

### Code Quality Tools

#### Linting

Install and run golangci-lint:

```bash
# Install
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Run
golangci-lint run
```

#### Formatting

Always format code before committing:

```bash
go fmt ./...
goimports -w .
```

#### Vetting

Check for suspicious code:

```bash
go vet ./...
```

## Testing Guidelines

### Testing Philosophy

- Write tests for all public functions
- Focus on behavior, not implementation
- Use table-driven tests for multiple scenarios
- Mock external dependencies

### Test Structure

```go
func TestUserController_CreateUser(t *testing.T) {
    tests := []struct {
        name           string
        requestBody    interface{}
        mockSetup      func(*mocks.MockUserUsecase)
        expectedStatus int
        expectedBody   string
    }{
        {
            name: "successful user creation",
            requestBody: model.User{
                Name:   "John Doe",
                Email:  "john@example.com",
                ImgURL: "https://example.com/img.jpg",
            },
            mockSetup: func(m *mocks.MockUserUsecase) {
                m.EXPECT().CreateUser(gomock.Any()).Return(model.User{
                    ID:     1,
                    Name:   "John Doe",
                    Email:  "john@example.com",
                    ImgURL: "https://example.com/img.jpg",
                }, nil)
            },
            expectedStatus: http.StatusCreated,
        },
        // ... more test cases
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test implementation
        })
    }
}
```

### Running Tests

```bash
# Run all tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run tests with race detection
go test -race ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Test Categories

#### Unit Tests
- Test individual functions/methods
- Mock all external dependencies
- Fast execution

#### Integration Tests
- Test component interactions
- Use test database
- Test real HTTP requests

#### End-to-End Tests
- Test complete user workflows
- Use Docker containers
- Test with real database

### Mocking

Use `gomock` for generating mocks:

```bash
# Install mockgen
go install github.com/golang/mock/mockgen@latest

# Generate mocks
mockgen -source=usecase/user_usecase.go -destination=mocks/mock_user_usecase.go
```

## Submitting Changes

### Before Submitting

1. **Update your branch** with the latest changes:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests**:
   ```bash
   go test ./...
   ```

3. **Run linters**:
   ```bash
   golangci-lint run
   ```

4. **Verify build**:
   ```bash
   go build ./...
   ```

### Creating a Pull Request

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a pull request** on GitHub with:
   - Clear title and description
   - Reference to related issues
   - Screenshots (if applicable)
   - Test results

### Pull Request Template

```markdown
## Description
Brief description of the changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## Review Process

### What We Look For

1. **Functionality**: Does the code work as intended?
2. **Code Quality**: Is the code clean and maintainable?
3. **Testing**: Are there adequate tests?
4. **Documentation**: Is documentation updated?
5. **Performance**: Are there any performance implications?
6. **Security**: Are there any security concerns?

### Review Timeline

- Initial review: 1-2 business days
- Follow-up reviews: 1 business day
- Approval: When all requirements are met

### Addressing Review Comments

1. **Make requested changes**
2. **Respond to comments** explaining your changes
3. **Request re-review** when ready

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH**
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

### Release Workflow

1. **Create release branch**: `release/v1.2.0`
2. **Update version numbers**
3. **Update CHANGELOG.md**
4. **Create release PR**
5. **Merge and tag release**
6. **Deploy to production**

## Getting Help

### Resources

- [Go Documentation](https://golang.org/doc/)
- [Gin Framework Documentation](https://gin-gonic.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### Community

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: [maintainer-email] for private concerns

### Common Issues

#### Build Problems

```bash
# Clean module cache
go clean -modcache

# Re-download dependencies
go mod download
```

#### Database Issues

```bash
# Reset database
docker-compose down -v
docker-compose up -d
```

#### Test Failures

```bash
# Run specific test
go test -v ./controller -run TestUserController_CreateUser

# Run with debug output
go test -v ./... -args -test.v
```

## Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes
- Annual contributor appreciation

Thank you for contributing to the Go API project! 🎉