#!/usr/bin/env bash

# Check if project name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <project-name> <laravel-version>"
  echo ""
  echo "Laravel versions can be found here : https://laravel.com/docs/11.x"
  exit 1
fi

# Check if laravel version is provided
if [ -z "$2" ]; then
  echo "Usage: $0 <project-name> <laravel-version>"
  exit 1
fi

# Check if docker is installed
if ! command -v docker &> /dev/null
then
  echo "Docker is not installed. Please install Docker and try again."
  exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null
then
  echo "Docker Compose is not installed. Please install Docker Compose and try again."
  exit 1
fi

docker-compose up -d

docker-compose run composer create-project laravel/laravel "$1" "$2.0.*" --prefer-dist

sleep 1

mv "$1"/* ./
rm -rf "$1"

# Ask if user want to automatically push to new remote repository
read -p "Do you want to automatically push to new remote repository? (y/n) " set_git_remote

case "$set_git_remote" in
  y|Y|yes)
    # Ask for repository url
    read -p "Enter repository url to push to: " repository_url

    # Set git remote
    git remote set-url origin "$repository_url"

    # Do initial commit and push
    git add .
    git commit -m "Initial commit for project '$1'"
    git push -u origin master
    ;;
  *)
    echo "Skipping git repository setup."
    ;;
esac

echo ""
echo "You need to rename the current directory to match your project name"
echo ""
echo "cd ../"
echo ""
echo "mv laravel-docker-template <project-name>"
echo ""
