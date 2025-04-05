# Use a smaller, secure base image
FROM node:18-alpine

# Set the build-time API URL
ARG VITE_API_BASE_URL

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install all dependencies including development dependencies
RUN npm install

# Inject the API base URL into the environment variable
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

# Copy the rest of the application code
COPY . .

# Build the Vite frontend (replaces env vars like VITE_API_BASE_URL)
RUN npm run build

# Expose the port for the development server
EXPOSE 5173

# Set the host to 0.0.0.0 to make the server accessible outside the container
ENV HOST=0.0.0.0

# Start the frontend development server
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
