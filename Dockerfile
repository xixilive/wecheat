FROM ruby:2.2-alpine

RUN mkdir /wecheat 
COPY . /wecheat
WORKDIR /wecheat
RUN bundle install
RUN rake setup

EXPOSE 9292

CMD ["rackup"]