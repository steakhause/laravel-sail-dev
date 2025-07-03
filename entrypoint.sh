#!/bin/bash

LARAVEL_ENV=/var/www/html/.env

# Make sure the .env file exists and is writable
if [ -f "$LARAVEL_ENV" ] && [ -w "$LARAVEL_ENV" ]; then
  echo "Injecting environment variables into Laravel .env..."

  declare -a keys=(
    APP_NAME APP_ENV APP_KEY APP_DEBUG APP_URL
    DB_CONNECTION DB_HOST DB_PORT DB_DATABASE DB_USERNAME DB_PASSWORD 
    MAIL_MAILER MAIL_HOST MAIL_PORT MAIL_USERNAME MAIL_PASSWORD MAIL_ENCRYPTION
  )

  for key in "${keys[@]}"; do
    value=$(printenv "$key")
    if [ -n "$value" ]; then
      # Replace existing or add new line
      if grep -q "^$key=" "$LARAVEL_ENV"; then
        sed -i "s|^$key=.*|$key=$value|" "$LARAVEL_ENV"
      else
        echo "$key=$value" >> "$LARAVEL_ENV"
      fi
    fi
  done

  echo "Final .env:"
  cat "$LARAVEL_ENV"
fi

exec "$@"
