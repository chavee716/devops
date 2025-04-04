# Use a smaller, secure base image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install all dependencies including development dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port for the development server
# Using 5173 which is the default for Vite
EXPOSE 5173

# Set the host to 0.0.0.0 to make the server accessible outside the container
ENV HOST=0.0.0.0

# Start the development server
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]