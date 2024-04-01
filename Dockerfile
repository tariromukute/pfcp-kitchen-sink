# Use an official Go runtime as a parent image
FROM golang:1.22-alpine AS builder

# Set the working directory to /app
WORKDIR /app

# Install system packages
RUN apk add --no-cache git
    
# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Install any required dependencies
RUN go get -u -v github.com/alvaroloes/enumer && \
    go install github.com/alvaroloes/enumer

# Copy the current directory contents into the container at /app
COPY . .

# Generate Go files using `enumer` package
RUN go generate ./pkg/pfcp

# Build the executable
RUN go build -o pfcpclient cmd/pfcpclient/main.go

# Start a new stage for running the application
FROM alpine:3.19 AS runtime

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /app/pfcpclient /app/

# Expose port 8805 for the app to listen on
EXPOSE 8805

# Serve the app using CMD
# CMD [ "/pfcpclient" ]
