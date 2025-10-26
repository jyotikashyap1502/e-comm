# Use official NGINX image
FROM nginx:alpine

# Copy build files to NGINX html folder
COPY devops-build/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start NGINX server
CMD ["nginx", "-g", "daemon off;"]
