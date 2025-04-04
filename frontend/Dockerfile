# Use a smaller, secure base image
FROM node:18-alpine AS build-stage

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the frontend for production
RUN npm run build

# Use Nginx to serve the built frontend
FROM nginx:alpine AS production-stage

# Copy the built frontend files to Nginx HTML directory
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Expose the port the frontend runs on
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
