FROM strapi/base:alpine as release

WORKDIR /app

COPY . ./

RUN yarn install

ENV NODE_ENV production

RUN yarn build

EXPOSE 1337

CMD ["yarn", "start"]