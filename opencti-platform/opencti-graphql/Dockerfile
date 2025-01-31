FROM node:20-alpine as build

RUN corepack enable && corepack prepare yarn@stable --activate && yarn set version 4.6.0
RUN apk add --no-cache python3 python3-dev py3-pip

WORKDIR /build

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn 
COPY patch ./patch
COPY src/python/requirements.txt ./src/python/requirements.txt


RUN pip3 install -r src/python/requirements.txt --no-cache-dir --break-system-packages

# RUN yarn install --immutable 
RUN yarn install --mode=update-lockfile

RUN ls -la

RUN yarn cache clean

COPY . .

RUN yarn build:dev


FROM node:20-alpine as runtime

RUN yarn set version 4.6.0

WORKDIR /app

COPY --from=build /build /app

RUN pip3 install -r src/python/requirements.txt --no-cache-dir --break-system-packages
RUN yarn install --production --immutable

EXPOSE 4000

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

ENTRYPOINT ["yarn"]
CMD ["serv"]