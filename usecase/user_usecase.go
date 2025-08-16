package usecase

import (
	"github.com/pytsx/goapi/model"
	"github.com/pytsx/goapi/repository"
)

type UserUsecase struct {
	repository repository.UserRepository
}

func NewUserUsecase(repo repository.UserRepository) UserUsecase {
	return UserUsecase{
		repository: repo,
	}
}

func (uu *UserUsecase) GetUsers() ([]model.User, error) {
	return uu.repository.GetUsers()
}

func (uu *UserUsecase) CreateUser(user model.User) (model.User, error) {
	uid, err := uu.repository.CreateUser(user)
	if err != nil {
		return model.User{}, err
	}

	user.ID = uid
	return user, nil
}

func (uu *UserUsecase) GetUser(id int) (*model.User, error) {
	return uu.repository.GetUser(id)
}
