# API Documentation

## Overview

This document provides detailed information about the User Management API endpoints, including request/response formats, error handling, and usage examples.

## Base Information

- **Base URL**: `http://localhost:8080`
- **Content-Type**: `application/json`
- **API Version**: 1.0.0

## Authentication

Currently, this API does not implement authentication. All endpoints are publicly accessible.

## Endpoints

### 1. Health Check

**Endpoint**: `GET /ping`

**Description**: Verifies that the API server is running and responding to requests.

**Request**: No parameters required

**Response**:
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
    "message": "pong"
}
```

**Example**:
```bash
curl -X GET http://localhost:8080/ping
```

---

### 2. Get All Users

**Endpoint**: `GET /users`

**Description**: Retrieves a list of all users in the system.

**Request**: No parameters required

**Response**:
```http
HTTP/1.1 200 OK
Content-Type: application/json

[
    {
        "user_id": 1,
        "name": "John Doe",
        "email": "john.doe@example.com",
        "img_url": "https://example.com/avatars/john.jpg"
    },
    {
        "user_id": 2,
        "name": "Jane Smith",
        "email": "jane.smith@example.com",
        "img_url": "https://example.com/avatars/jane.jpg"
    }
]
```

**Error Response**:
```http
HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
    "error": "Database connection error"
}
```

**Example**:
```bash
curl -X GET http://localhost:8080/users
```

---

### 3. Get User by ID

**Endpoint**: `GET /user/{id}`

**Description**: Retrieves a specific user by their unique ID.

**Path Parameters**:
- `id` (integer, required): The unique identifier of the user

**Request**: No body required

**Success Response**:
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
    "user_id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "img_url": "https://example.com/avatars/john.jpg"
}
```

**Error Responses**:

*Missing ID Parameter*:
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
    "message": "Essa rota espera receber um id como parâmetro"
}
```

*Invalid ID Format*:
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
    "message": "Essa rota espera receber um id numérico"
}
```

*User Not Found*:
```http
HTTP/1.1 404 Not Found
Content-Type: application/json

{
    "message": "Nenhum usuário foi localizado com o id fornecido"
}
```

*Internal Server Error*:
```http
HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
    "error": "Database error message"
}
```

**Examples**:
```bash
# Valid request
curl -X GET http://localhost:8080/user/1

# Invalid ID format
curl -X GET http://localhost:8080/user/abc

# Non-existent user
curl -X GET http://localhost:8080/user/999
```

---

### 4. Create User

**Endpoint**: `POST /user`

**Description**: Creates a new user in the system.

**Request Body**:
```json
{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "img_url": "https://example.com/avatars/john.jpg"
}
```

**Request Body Parameters**:
- `name` (string, required): The user's full name
- `email` (string, required): The user's email address
- `img_url` (string, optional): URL to the user's profile image

**Success Response**:
```http
HTTP/1.1 201 Created
Content-Type: application/json

{
    "user_id": 3,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "img_url": "https://example.com/avatars/john.jpg"
}
```

**Error Responses**:

*Invalid JSON Body*:
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
    "error": "Invalid JSON format"
}
```

*Internal Server Error*:
```http
HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
    "error": "Database error message"
}
```

**Examples**:
```bash
# Valid request
curl -X POST http://localhost:8080/user \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "img_url": "https://example.com/alice.jpg"
  }'

# Minimal request (without image URL)
curl -X POST http://localhost:8080/user \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Bob Wilson",
    "email": "bob@example.com"
  }'

# Invalid JSON
curl -X POST http://localhost:8080/user \
  -H "Content-Type: application/json" \
  -d '{"name": "Invalid JSON"'
```

## Data Models

### User Model

```go
type User struct {
    ID     int    `json:"user_id"`
    Name   string `json:"name"`
    Email  string `json:"email"`
    ImgURL string `json:"img_url"`
}
```

**Field Descriptions**:
- `user_id`: Unique identifier (auto-generated)
- `name`: User's full name
- `email`: User's email address
- `img_url`: URL to user's profile image (optional)

### Response Model

```go
type Response struct {
    Message string `json:"message"`
}
```

**Field Descriptions**:
- `message`: Human-readable message for error or informational responses

## HTTP Status Codes

The API uses standard HTTP status codes:

- `200 OK`: Request successful
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request data or parameters
- `404 Not Found`: Requested resource not found
- `500 Internal Server Error`: Server-side error

## Error Handling

All endpoints follow consistent error handling patterns:

1. **Validation Errors** (400): Returned when request data is invalid or missing required parameters
2. **Not Found Errors** (404): Returned when requested resources don't exist
3. **Server Errors** (500): Returned when database or internal server errors occur

Error responses include descriptive messages to help identify the issue.

## Rate Limiting

Currently, no rate limiting is implemented. Consider implementing rate limiting for production use.

## CORS

Cross-Origin Resource Sharing (CORS) is not explicitly configured. The default Gin behavior applies.

## Content Negotiation

The API currently only supports JSON format for both requests and responses.

## Testing the API

### Using curl

All examples in this document use curl. Ensure your requests include the appropriate `Content-Type` header for POST requests.

### Using Postman

1. Import the following collection settings:
   - Base URL: `http://localhost:8080`
   - Content-Type: `application/json`

2. Create requests for each endpoint using the examples provided above.

### Response Validation

Verify API responses match the documented formats and status codes for both success and error scenarios.