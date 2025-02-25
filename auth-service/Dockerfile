# Use a smaller, secure base image
FROM node:18-alpine

# Set environment variable to production
ENV NODE_ENV=production

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy the rest of the application code
COPY . .

# Use a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose the port your backend runs on (change if needed)
EXPOSE 3001

# Start the backend server
CMD ["npm", "start"]
