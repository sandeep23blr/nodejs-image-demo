FROM node:10-alpine

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

WORKDIR /home/node/app

COPY package*.json ./

USER node

RUN npm install

# Copy the entire application directory, including views
COPY --chown=node:node . .

# Make sure to copy the views directory specifically if needed
# COPY /home/ec2-user/node_project/views /home/node/app/views

EXPOSE 8082

CMD [ "node", "app.js" ]
