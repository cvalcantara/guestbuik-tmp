FROM golang:1.23-alpine AS builder

WORKDIR /app

# Instalar dependências do sistema
RUN apk add --no-cache git

# Copiar apenas go.mod primeiro
COPY go.mod ./

# Inicializar módulo e download das dependências
RUN go mod download
RUN go mod tidy

# Copiar código fonte
COPY . .

# Build da aplicação
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Imagem final
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

# Copiar binário compilado
COPY --from=builder /app/main .

# Copiar arquivos estáticos
COPY ./public/ ./public/

EXPOSE 3000

CMD ["./main"]
