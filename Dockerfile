# Dockerfile
FROM ruby:3.3.0

# Instala dependencias del sistema
RUN apt-get update -qq && apt-get install -y build-essential libmariadb-dev nodejs yarn

# Crea directorio para la app
WORKDIR /app

# Copia Gemfile y Gemfile.lock primero para evitar reinstalar gems en cada build
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copia el resto de la app
COPY . .

# Expone el puerto que usa Puma
EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bin/rails server -b 0.0.0.0"]
