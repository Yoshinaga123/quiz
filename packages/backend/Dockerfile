# syntax=docker/dockerfile:1.7
# Dev compose and production compose both use the repository root as context.

FROM golang:1.26-alpine AS dev
WORKDIR /app
RUN apk add --no-cache python3 git
RUN go install github.com/air-verse/air@latest
RUN go install github.com/golang-migrate/migrate/v4/cmd/migrate@v4.19.1
COPY packages/backend/go.mod packages/backend/go.sum ./
RUN go mod download
EXPOSE 8080
CMD ["air", "-c", ".air.toml"]

FROM golang:1.26-alpine AS build-env
WORKDIR /src
RUN apk add --no-cache git
COPY packages/backend/go.mod packages/backend/go.sum ./
RUN go mod download
COPY packages/backend/ ./
RUN go build -o /out/server .
RUN go install github.com/golang-migrate/migrate/v4/cmd/migrate@v4.19.1

FROM alpine:3.19 AS runtime
RUN apk add --no-cache python3 ca-certificates
WORKDIR /app
COPY --from=build-env /out/server /app/server
COPY --from=build-env /go/bin/migrate /usr/local/bin/migrate
COPY --from=build-env /src/migrations /app/migrations
COPY scripts/generate_migration.py /app/scripts/generate_migration.py
COPY packages/admin-web/src/data/quizzes.json /app/data/quizzes.json
ENV QUIZ_SEED_GENERATOR_SCRIPT=/app/scripts/generate_migration.py
ENV QUIZ_SEED_PATH=/app/data/quizzes.json
ENV QUIZ_MIGRATIONS_DIR=/app/migrations
ENV QUIZ_PYTHON_BIN=python3
ENV QUIZ_MIGRATE_BIN=/usr/local/bin/migrate
EXPOSE 8080
CMD ["./server"]
