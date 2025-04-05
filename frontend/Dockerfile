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
EXPOSE 5173

# Set the host to 0.0.0.0 to make the server accessible outside the container
ENV HOST=0.0.0.0

# Inject build-time API URL if needed
ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

# Start the development server
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
