FROM node:16 as release

# Installing libvips-dev for sharp compatability
RUN apt-get update -qq && apt-get install -y libvips-dev

ARG NODE_ENV=development
ARG DATABASE_PORT
ARG DATABASE_NAME
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD

ENV NODE_ENV=$NODE_ENV
ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_PORT=$DATABASE_PORT
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USERNAME=$DATABASE_USERNAME
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD

WORKDIR /opt/
COPY ./package.json ./
COPY ./yarn.lock ./

ENV PATH /opt/node_modules/.bin:$PATH
RUN yarn config set network-timeout 600000 -g
RUN yarn install

WORKDIR /opt/app
COPY ./ .

RUN yarn build
EXPOSE 1337

CMD ["yarn", "start"]