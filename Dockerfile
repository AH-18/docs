# syntax=docker/dockerfile:1

# NOTE: This image intentionally runs `pnpm run build` at container startup so
# environment variables provided at `docker run` time (e.g. `--env-file`) are
# available during the Docusaurus build.

FROM node:24-bookworm-slim AS deps

WORKDIR /repo

# Use Corepack so the pnpm version is managed by Node.
ENV PNPM_HOME=/pnpm
ENV PATH=$PNPM_HOME:$PATH

RUN corepack enable

# This Dockerfile must be built with the repository root as the build context, e.g.:
#   docker build -f Dockerfile -t docusaurus-site:latest .
# because the Docusaurus site depends on workspace packages in /packages.

# Copy workspace + package manifests first for better layer caching.
COPY pnpm-workspace.yaml pnpm-lock.yaml ./
COPY docusaurus/package.json ./docusaurus/package.json
COPY packages/docusaurus-plugin-reactor-docgen/package.json ./packages/docusaurus-plugin-reactor-docgen/package.json
COPY packages/docusaurus-theme-reactor-docgen/package.json ./packages/docusaurus-theme-reactor-docgen/package.json

# Install all workspace dependencies (root has no package.json, so we use recursive mode).
RUN pnpm -r install --frozen-lockfile

# Bring in the rest of the sources (but do NOT build here).
COPY . .


FROM node:24-bookworm-slim AS runtime

WORKDIR /repo

ENV PNPM_HOME=/pnpm
ENV PATH=$PNPM_HOME:$PATH

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

RUN corepack enable

COPY --from=deps /repo /repo

WORKDIR /repo/docusaurus

ENV PORT=3000

# Normalize CRLF in case this repo was checked out on Windows.
RUN sed -i 's/\r$//' ./docker-entrypoint.sh

EXPOSE 3000

CMD ["sh", "./docker-entrypoint.sh"]
