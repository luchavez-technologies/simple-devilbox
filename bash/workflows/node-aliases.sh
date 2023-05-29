# This will change the port where the node app will be expected to run on
function port_change() {
  php_version=$(php_version)
  if [ $# -eq 0 ]; then
    echo "👀 Please enter $(style "vhost" underline bold)"
    read -r vhost

    if [ -z "$vhost" ]; then
      echo_error "The vhost is empty!"
      stop_function
    fi

    echo "👀 Please enter $(style "port number" underline bold) where the app should run:"
    read -r port

    if [ -z "$port" ]; then
      echo_error "The port number is empty!"
      stop_function
    fi

    echo "Here are the available PHP containers: $(style php blue bold), $(style php54 blue bold), $(style php55 blue bold), $(style php56 blue bold), $(style php70 blue bold), $(style php71 blue bold), $(style php72 blue bold), $(style php73 blue bold), $(style php74 blue bold), $(style php80 blue bold), $(style php81 blue bold), $(style php82 blue bold)"
    echo "👀 Please enter $(style "PHP container" underline bold) to run the app on (default: $(style "$php_version" bold blue)):"
    read -r version

    if [ -n "$version" ] && is_php_container_valid "$version"; then
      php_version=$version
    fi
  else
    if [ -n "$1" ]; then
      vhost=$1
    else
      echo_error "The vhost is empty!"
      stop_function
    fi

    if [ -n "$2" ]; then
      port=$2
    else
      echo_error "The port number is empty!"
      stop_function
    fi

    if [ -n "$3" ]; then
      php_version=$3
    fi
  fi

  cd /shared/httpd || stop_function

  if [ -d "$vhost" ]; then
    cd "$vhost" || stop_function

    if [ -n "$port" ]; then
      mkdir .devilbox 2>/dev/null
      touch .devilbox/backend.cfg 2>/dev/null
      echo "conf:rproxy:http:$php_version:$port" > .devilbox/backend.cfg
      reload_watcherd_message
    fi
  fi
}

# Execute npm or yarn commands
function npm_yarn() {
  args=""
  if [ $# -gt 0 ]; then
    args=$*
  fi

  prepend=""
  if [ -f package-lock.json ]; then
    prepend=npm
  elif [ -f yarn.lock ]; then
    prepend=yarn
  elif [ -f package.json ]; then
    prepend=npm
  fi

  if [ -n "$prepend" ]; then
    style "🙏 $prepend $args" bold green
    $prepend $args
  fi
}

# Install NPM dependencies
function npm_yarn_install() {
  args=""
  if [ $# -gt 0 ]; then
    args=$*
  fi

  if [ ! -d node_modules ]; then
    npm_yarn install $args
  else
    echo_error "Dependencies are already installed."
  fi
}

# Install NPM dependencies for production
function npm_yarn_install_production() {
  npm_yarn_install --production
}

# Execute npm or yarn commands
function npm_yarn_run() {
  args=""
  if [ $# -eq 0 ]; then
    echo_error "Missing arguments!"
  elif [ -d node_modules ]; then
    args=$*
    npm_yarn run $args
  else
    echo_error "Dependencies are not yet installed."
  fi
}

# Run project (NodeJS apps)
function project_start() {
  scripts=("dev" "develop" "development" "start")

  for script in "${scripts[@]}"
  do
    if grep -q "\"$script\"" package.json ; then
      npm_yarn_run "$script"
      break
    fi
  done
}

# Set devilbox as the owner of /opt/nvm directory
function own_nvm() {
  own_directory /opt/nvm
}

# Own NVM automatically by devilbox user
own_nvm