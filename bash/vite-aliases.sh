# Create and run a new ViteJS app
function vite_new() {
  vite_version="latest"
  # check if no argument is given
  if [ $# -eq 0 ]; then
    # ask for app name
    echo "Please enter ViteJS app name (default: 'app-x'):"
    read -r name
    # check if input is empty
    if [ -z "$name" ]; then
      name="app-$RANDOM"
    fi

    # ask for ViteJS version
    echo "Please enter ViteJS version (default: 'latest'):"
    read -r vite_version
  else
    # set as name input is not empty
    if [ -n "$1" ]; then
      name=$1
    fi

    # set as vite_version if input is not empty
    if [ -n "$2" ]; then
      vite_version=$2
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  # create vhost
  mkdir "$name"

  # cd to vhost
  cd "$name" || stop_function

  # create new laravel app based on the inputs
  npx create-vite@"$vite_version" "$name"

  # add the devilbox config
  port_change "$name" 5173

  # cd to project
  cd "$name" || stop_function

  # make sure to expose ViteJS to the Docker network
  text_replace "\"dev\": \"vite\"" "\"dev\": \"vite --host\"" "package.json"

  # install dependencies
  npm install

  # exit message
  echo_success "Welcome to your new app ($name)! Happy coding! 🎉"
  echo_success "Here's your app URL: https://$name.dvl.to"

  # run the app
  npm run dev
}

# Clone and run a ViteJS app
function vite_clone() {
  url=""
  # check if no argument is given
  if [ $# -eq 0 ]; then
    # ask for Git URL
    echo "Please enter Git URL of your ViteJS app:"
    read -r url
    # check if input is empty
    if [ -z "$url" ]; then
      # do something if input is empty
      echo_error "You provided an empty Git URL."
      stop_function
    fi

    # ask for app name
    echo "Please enter ViteJS app name (default: 'app-x'):"
    read -r name
    # check if input is empty
    if [ -z "$name" ]; then
      # do something if input is empty
      name="app-$RANDOM"
    fi
  else
    # check if input is not empty
    if [ -n "$1" ]; then
      url=$1
    fi

    # check if input is not empty
    if [ -n "$2" ]; then
      # do something if input is empty
      name=$2
    fi
  fi

  # make sure to come back first to root
  cd /shared/httpd || stop_function

  # create vhost
  mkdir "$name"

  # cd to vhost
  cd "$name" || stop_function

  # create new laravel app based on the inputs
  git clone "$url" "$name"

  # add the devilbox config
  port_change "$name" 5173

  # cd to project
  cd "$name" || stop_function

  # yarn or npm
  runner=""
  if [ -f "yarn.lock" ]; then
    runner="yarn"
  else
    runner="npm"
  fi

  # make sure to expose ViteJS to the Docker network
  text_replace "\"dev\": \"vite\"" "\"dev\": \"vite --host\"" "package.json"

  # install dependencies
  $runner install

  # exit message
  echo_success "Welcome to your newly cloned app ($name)! Happy coding! 🎉"
  echo_success "Here's your app URL: https://$name.dvl.to"

  # run the app
  $runner run dev
}