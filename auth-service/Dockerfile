# Use a smaller, secure base image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install only production dependencies
RUN npm install 

# Copy the rest of the application code
COPY . .

# Expose the port your backend runs on (change if needed)
EXPOSE 5000

# Start the backend server
CMD ["npm", "start"]
