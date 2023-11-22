# syntax=docker/dockerfile:1
FROM node:18-bullseye-slim AS base
RUN mkdir /app

FROM base as deps
WORKDIR /app
ADD package.json package-lock.json ./
RUN npm ci

FROM base as production-deps
ENV NODE_ENV production
WORKDIR /app
COPY --from=deps /app/node_modules /app/node_modules
ADD package.json package-lock.json ./
RUN npm prune --production

FROM base as build
WORKDIR /app
COPY --from=deps /app/node_modules /app/node_modules
ADD . .
RUN npm run build

FROM base as app
ENV NODE_ENV production
WORKDIR /app
COPY --from=production-deps /app/node_modules /app/node_modules
COPY --from=build /app/build /app/build
COPY --from=build /app/public /app/public
ADD . .
CMD ["npm", "run", "start"]