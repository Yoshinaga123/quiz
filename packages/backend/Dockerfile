FROM golang:1.26-alpine AS dev
WORKDIR /app
RUN apk add --no-cache python3
RUN go install github.com/air-verse/air@latest
RUN go install github.com/golang-migrate/migrate/v4/cmd/migrate@v4.19.1
COPY go.mod go.sum ./
RUN go mod download
EXPOSE 8080
CMD ["air", "-c", ".air.toml"]

FROM golang:1.26-alpine AS build-env
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . /app
RUN go build -o server .

FROM alpine:3.19 AS runtime
COPY --from=build-env /app/server /app/server
WORKDIR /app
EXPOSE 8080
CMD ["./server"]
