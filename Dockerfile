FROM golang:1.22.5

# Define o diretório no qual iremos trabalhar
WORKDIR /go/src/app

# copia o código-fonte
COPY . .

# expõe a porta da api
EXPOSE 8080

# Builda o código-fonte
RUN go build -o main cmd/api/main.go

# roda o executável
CMD ["./main"]