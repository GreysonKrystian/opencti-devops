FROM node:20-alpine AS build

RUN corepack enable && corepack prepare yarn@stable --activate && yarn set version 4.6.0
RUN apk add --no-cache python3 python3-dev py3-pip alpine-sdk

WORKDIR /
COPY ./opencti-front/src/schema/relay.schema.graphql ./opencti-front/src/schema/relay.schema.graphql

WORKDIR /build
COPY ./opencti-graphql/package.json ./opencti-graphql/yarn.lock ./opencti-graphql/.yarnrc.yml ./
COPY ./opencti-graphql/.yarn ./.yarn 
COPY ./opencti-graphql/patch ./patch
COPY ./opencti-graphql/src/python/requirements.txt ./src/python/requirements.txt

RUN pip3 install -r src/python/requirements.txt --no-cache-dir --break-system-packages

RUN yarn install

RUN yarn cache clean

COPY ./opencti-graphql/ .

RUN yarn build:dev

FROM node:20-alpine AS runtime

RUN yarn set version 4.6.0
RUN apk add --no-cache python3 python3-dev py3-pip

WORKDIR /app

COPY --from=build /build /app


RUN pip3 install -r src/python/requirements.txt --no-cache-dir --break-system-packages


EXPOSE 4000

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

#TODO envs

ENTRYPOINT ["yarn"]
CMD ["serv"]