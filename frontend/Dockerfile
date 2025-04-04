# Use a smaller, secure base image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Update the Vite configuration to allow external connections
RUN sed -i 's/export default defineConfig({/export default defineConfig({\n  server: {\n    host: "0.0.0.0",\n    port: 5173,\n    strictPort: true\n  },/' vite.config.js

# Expose the port your frontend runs on
EXPOSE 5173

# Start the frontend server with host binding to allow external connections
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]