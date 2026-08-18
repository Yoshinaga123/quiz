# syntax=docker/dockerfile:1.7
# Build context must be the repository root (see deploy/lightsail/docker-compose.yml).

FROM node:22-alpine AS dev
WORKDIR /app
COPY packages/web/package.json ./
RUN npm install
EXPOSE 5174
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5174"]

FROM node:22-alpine AS build
WORKDIR /app
COPY packages/web/package.json ./
RUN npm install
COPY tsconfig.base.json /tsconfig.base.json
COPY packages/web/ .
ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
# Typecheck stays in CI. The image only needs the Vite bundle.
RUN npx vite build

FROM nginx:1.27-alpine AS runtime
COPY --from=build /app/dist /usr/share/nginx/html
COPY packages/web/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz || exit 1
CMD ["nginx", "-g", "daemon off;"]
