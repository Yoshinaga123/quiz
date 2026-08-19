# syntax=docker/dockerfile:1.7
# Build context must be the monorepo root (needs tsconfig.base.json).

FROM node:22-alpine AS build
WORKDIR /src
COPY tsconfig.base.json ./
COPY packages/web/package.json packages/web/package-lock.json* ./packages/web/
WORKDIR /src/packages/web
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
COPY packages/web/ ./
ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
# App project only — skip tsconfig.node (vitest) inside the image
RUN npx tsc -b tsconfig.app.json && npx vite build

FROM nginx:1.27-alpine AS runtime
COPY --from=build /src/packages/web/dist /usr/share/nginx/html
COPY packages/web/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz || exit 1
CMD ["nginx", "-g", "daemon off;"]
