# ---- Build: compile the Vite/React SPA to static assets ----
FROM node:22-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Vite inlines VITE_* variables into the JS bundle at build time, so this
# has to be a build arg (see docker-compose.yml's build.args), not a
# runtime environment variable -- the static files served below can no
# longer read env vars at container start.
ARG VITE_API_BASE_URL=http://localhost:8000
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
RUN npm run build

# ---- Serve: nginx, unprivileged ----
FROM nginx:1.27-alpine AS serve

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html

# Run as the image's existing non-root "nginx" user on an unprivileged
# port, matching the backend image -- neither container needs root.
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx
USER nginx

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
