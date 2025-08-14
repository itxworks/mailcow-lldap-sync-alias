FROM golang:1.24-alpine AS builder

RUN apk add bash ca-certificates git gcc g++ libc-dev

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY main.go .

RUN go build -ldflags="-s -w" -o email-check main.go

FROM alpine:latest
RUN apk update && apk add ca-certificates \
    && rm -rf /var/cache/apk/*

RUN apk add --no-cache --upgrade bash
RUN apk add --no-cache ca-certificates tzdata bash curl


COPY --from=builder /app/email-check /app/email-check
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && touch /var/log/cron.log

ENV CRON_SCHEDULE="*/10 * * * *"

CMD ["/entrypoint.sh"]
