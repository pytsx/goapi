package controller

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/pytsx/goapi/model"
	"github.com/pytsx/goapi/usecase"
)

type UserController struct {
	userUsecase usecase.UserUsecase
}

func NewUserController(usecase usecase.UserUsecase) UserController {
	return UserController{
		userUsecase: usecase,
	}
}

func (uc *UserController) GetUsers(ctx *gin.Context) {
	products, err := uc.userUsecase.GetUsers()

	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, products)
}

func (uc *UserController) CreateUser(ctx *gin.Context) {

	var user model.User
	// popula o objeto ´user´ com os valores passados na requisição. Caso não corresponda com um user, retorna um erro para o requisitante
	err := ctx.BindJSON(&user)
	if err != nil {
		// informa que o erro foi da aplicação requisitante
		ctx.JSON(http.StatusBadRequest, err)
		return
	}

	// chama o usecase para criar o usuário
	insertedUser, err := uc.userUsecase.CreateUser(user)

	if err != nil {
		// aconteceu um erro no ´userRepository´, portanto foi interno da aplicação
		ctx.JSON(http.StatusInternalServerError, err)
		return
	}

	ctx.JSON(http.StatusCreated, insertedUser)
}

func (uc *UserController) GetUser(ctx *gin.Context) {
	id := ctx.Param("id")
	if id == "" {
		response := model.Response{
			Message: "Essa rota espera receber um id como parâmetro",
		}
		ctx.JSON(http.StatusBadRequest, response)
		return
	}

	safeId, err := strconv.Atoi(id)
	if err != nil {
		response := model.Response{
			Message: "Essa rota espera receber um id numérico",
		}
		ctx.JSON(http.StatusBadRequest, response)
		return
	}

	user, err := uc.userUsecase.GetUser(safeId)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, err)
		return
	}

	if user == nil {
		response := model.Response{
			Message: "Nenhum usuário foi localizado com o id fornecido",
		}
		ctx.JSON(http.StatusNotFound, response)
		return
	}

	ctx.JSON(http.StatusOK, user)
}
