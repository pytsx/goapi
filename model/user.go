package model

type User struct {
	ID     int    `json:"user_id"`
	Name   string `json:"name"`
	Email  string `json:"email"`
	ImgURL string `json:"img_url"`
}