package repository

import (
	"database/sql"

	"github.com/pytsx/goapi/model"
)

type UserRepository struct {
	connection *sql.DB
}

func NewUserRepository(conn *sql.DB) UserRepository {

	return UserRepository{
		connection: conn,
	}
}

func (ur *UserRepository) GetUsers() ([]model.User, error) {
	query := "SELECT id, name, email, img_url FROM users"
	rows, err := ur.connection.Query(query)

	if err != nil {
		return []model.User{}, err
	}

	var usersList []model.User
	var userObj model.User

	for rows.Next() {
		err := rows.Scan(
			&userObj.ID,
			&userObj.Name,
			&userObj.Email,
			&userObj.ImgURL,
		)

		if err != nil {
			return []model.User{}, err
		}

		usersList = append(usersList, userObj)
	}

	rows.Close()

	return usersList, nil
}

func (ur *UserRepository) CreateUser(user model.User) (int, error) {
	var id int

	query, err := ur.connection.Prepare("INSERT INTO user " +
		"(user_name, user_email, user_imgurl)" +
		" VALUES ($1, $2, $3) RETURNING user_id")
	if err != nil {
		return -1, err
	}

	err = query.QueryRow(user.Name, user.Email, user.ImgURL).Scan(&id)
	if err != nil {
		return -1, err
	}

	query.Close()
	return id, nil
}

func (ur *UserRepository) GetUser(id int) (*model.User, error) {
	query, err := ur.connection.Prepare("SELECT * FROM users WHERE id = $1")
	if err != nil {
		return nil, err
	}

	var user model.User

	err = query.QueryRow(id).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.ImgURL,
	)

	if err != nil {
		if err == sql.ErrConnDone {
			return nil, nil
		}
		return nil, err
	}

	query.Close()

	return &user, nil
}
