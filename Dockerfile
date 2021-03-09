FROM elixir:1.11

RUN curl -fsSL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY mix.exs /app/

# Install elixir dependencies
RUN mix local.hex --force && mix local.rebar --force && mix deps.get && mix deps.compile

# Install nodejs dependencies
COPY assets /app/assets
WORKDIR /app/assets/
RUN npm install

ENV LC_ALL en_US.UTF-8
WORKDIR /app