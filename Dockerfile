FROM jruby:1.7-onbuild
ADD .
WORKDIR .
RUN bundle install
