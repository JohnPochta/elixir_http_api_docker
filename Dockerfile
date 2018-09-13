FROM bitwalker/alpine-elixir:1.6.6
COPY . .
RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix local.hex --force && \
    mix deps.get && \
    mix release.init && \
    MIX_ENV=prod mix release

RUN cp _build/prod/rel/test/releases/0.1.0/test.tar.gz /opt/app/
RUN cd /opt/app/
RUN tar -xzf test.tar.gz

EXPOSE 4000

ENTRYPOINT ["/opt/app/bin/test"]
CMD ["foreground"]
