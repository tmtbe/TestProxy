FROM golang:1.17-alpine as builder
WORKDIR /app
COPY . .
RUN go mod tidy \
    && CGO_ENABLED=0 GOOS=linux go build -o collector

FROM scratch
WORKDIR /app
COPY --from=builder /app/collector .
EXPOSE 80
ENTRYPOINT ["./collector"]