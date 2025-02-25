# Use an official Node.js runtime as base
FROM node:18

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Expose the service port
EXPOSE 5000

# Start the application
CMD ["npm", "start"]
