# ---------- Client build ----------
FROM node:18-alpine AS client-build
WORKDIR /app/client
 
COPY client/package*.json ./
RUN npm ci
 
COPY client .
RUN npm run build
 
 
# ---------- Server build ----------
FROM node:18-alpine AS server-build
WORKDIR /app/server
 
COPY server/package*.json ./
RUN npm ci
 
COPY server .
 
 
# ---------- Production image ----------
FROM node:18-alpine
WORKDIR /app
 
# Install serve for frontend
RUN npm install -g serve
 
# Copy server & client
COPY --from=server-build /app/server ./server
COPY --from=client-build /app/client/dist ./client/dist
 
# Startup script
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'cd /app/server && node index.js &' >> /app/start.sh && \
    echo 'serve -s /app/client/dist -l 5173' >> /app/start.sh && \
    chmod +x /app/start.sh
 
# Expose ports
EXPOSE 5173
EXPOSE 8000
 
ENV NODE_ENV=production
 
CMD ["/app/start.sh"]
