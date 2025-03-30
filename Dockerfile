# Build stage for frontend
FROM node:18-alpine as frontend-builder

WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package*.json ./

# Install frontend dependencies
RUN npm ci

# Copy frontend source code
COPY frontend/ ./

# Build frontend with production configuration
COPY frontend/.env.production ./.env
RUN npm run build

# Build stage for auth service
FROM node:18-alpine as auth-builder

WORKDIR /app/auth-service

# Copy auth service package files
COPY auth-service/package*.json ./

# Install auth service dependencies
RUN npm ci

# Copy auth service source code
COPY auth-service/ ./

# Production stage
FROM node:18-alpine

# Install nginx for serving frontend
RUN apk add --no-cache nginx

# Create app directory
WORKDIR /app

# Copy built frontend
COPY --from=frontend-builder /app/frontend/build /app/frontend

# Copy auth service
COPY --from=auth-builder /app/auth-service /app/auth-service

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose ports
EXPOSE 80 443 3000 3001

# Start services
CMD ["/app/start.sh"] 