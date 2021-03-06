FROM node:13.7 as base

# install chrome for protractor tests
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -yq google-chrome-stable

WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules:$PATH

# install and cache app dependencies
COPY package.json /app/package.json

RUN ["npm", "install"]
RUN ["npm", "install", "-g", "@angular/cli"]

# add app
COPY . /app

# run tests
RUN ng test --watch=false
RUN ng e2e --port 4202

FROM base as dev-stage

# start app
CMD ["npm", "start", "--", "--host", "0.0.0.0", "--poll", "500"]
 
# docker build -t logbyinterceptor-dev .
# docker run -it -v ${PWD}/src:/app/src -p 4201 --rm logbyinterceptor-dev

FROM base as build-stage

# generate build
 RUN ng build --prod --output-path=dist

# start app
CMD ["npm", "start", "--", "--host", "0.0.0.0","--poll", "500"]