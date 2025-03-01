FROM rust:1.85 as builder

WORKDIR /app
COPY . .

# Build dependencies first (for better caching)
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install necessary runtime dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from builder
COPY --from=builder /app/target/release/dispatch /usr/local/bin/dispatch

EXPOSE 8080

CMD ["dispatch"] 