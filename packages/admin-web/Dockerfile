# syntax=docker/dockerfile:1.7
FROM node:22-alpine AS build
WORKDIR /src
COPY tsconfig.base.json ./
COPY package.json package-lock.json ./
COPY packages/web/package.json ./packages/web/
COPY packages/admin-web/package.json ./packages/admin-web/
RUN npm ci --workspace packages/admin-web --include-workspace-root
COPY packages/admin-web/ ./packages/admin-web/
WORKDIR /src/packages/admin-web
ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
RUN npx tsc -b tsconfig.app.json && npx vite build --base=/admin/

FROM nginx:1.27-alpine AS runtime
COPY --from=build /src/packages/admin-web/dist /usr/share/nginx/html
COPY packages/admin-web/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz || exit 1
CMD ["nginx", "-g", "daemon off;"]
