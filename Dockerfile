ARG GO_VERSION=1.27.0

FROM golang:${GO_VERSION}-alpine AS builder

RUN apk add --no-cache bash ca-certificates git gcc g++ libc-dev

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY main.go .

RUN go build -ldflags="-s -w" -o email-check main.go

FROM alpine:latest

# Install dependencies - use busybox's crond instead of dcron
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
        ca-certificates \
        bash \
        tzdata \
        curl \
        busybox-suid \
        && rm -rf /var/cache/apk/*


# Set timezone
ENV TZ=UTC

COPY --from=builder /app/email-check /app/email-check
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && touch /var/log/cron.log

ENV CRON_SCHEDULE="*/10 * * * *"

CMD ["/entrypoint.sh"]
