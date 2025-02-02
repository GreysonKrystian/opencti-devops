FROM node:20-alpine AS build

ARG FRONTEND_LOCATION=./opencti-front

RUN corepack enable && corepack prepare yarn@stable --activate && yarn set version 4.6.0

WORKDIR /build
COPY $FRONTEND_LOCATION/package.json $FRONTEND_LOCATION/yarn.lock $FRONTEND_LOCATION/.yarnrc.yml ./
COPY $FRONTEND_LOCATION/.yarn ./.yarn 
COPY $FRONTEND_LOCATION/patch ./patch
COPY opencti-front/packages ./packages

RUN yarn install
RUN yarn cache clean

COPY $FRONTEND_LOCATION/ .

RUN yarn build

FROM node:20-alpine AS runtime

RUN yarn set version 4.6.0

WORKDIR /app

COPY --from=build /build /app


EXPOSE 3000

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

#TODO envs

ENTRYPOINT ["yarn"]
CMD ["start"]