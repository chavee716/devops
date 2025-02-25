# Use an official Node.js runtime as a build stage
FROM node:18 AS build

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Fix permission issue for Vite
RUN chmod +x node_modules/.bin/vite

# Run the build command explicitly from the correct path
RUN npx vite build

# Use nginx to serve the build files
FROM nginx:latest
COPY --from=build /app/dist /usr/share/nginx/html

# Expose the default Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
