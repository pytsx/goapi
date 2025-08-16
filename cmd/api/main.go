package main

import (
	gin "github.com/gin-gonic/gin"
	"github.com/pytsx/goapi/controller"
	"github.com/pytsx/goapi/db"
	"github.com/pytsx/goapi/repository"
	"github.com/pytsx/goapi/usecase"
)

func main() {
	server := gin.Default()

	dbConnection, err := db.ConnectDB()
	if err != nil {
		panic(err)
	}

	userRepo := repository.NewUserRepository(dbConnection)
	userUsecase := usecase.NewUserUsecase(userRepo)
	userController := controller.NewUserController(userUsecase)

	server.GET("/ping", func(ctx *gin.Context) {
		ctx.JSON(200, gin.H{
			"message": "pong",
		})
	})

	server.GET("/users", userController.GetUsers)
	server.GET("/user/:id", userController.GetUser)
	server.POST("/user", userController.CreateUser)

	server.Run(":8080")
}
