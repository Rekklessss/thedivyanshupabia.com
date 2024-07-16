# Use the official Node.js image as the base image for building the application
FROM node:14 AS builder

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY retro-website/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY retro-website .

# Build the application
RUN npm run build

# Use the official Nginx image as the base image for serving the built application
FROM nginx:alpine

# Copy built application from the previous stage
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html/retro-website/dist

# Copy custom Nginx configuration
COPY nginx/default /etc/nginx/nginx.conf

# Expose the port Nginx is running on
EXPOSE 80
EXPOSE 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]