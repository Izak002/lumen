#!/bin/bash

# script for running my ruby file [im just lazy 🌙✨]
# lets set -e so that this stops if a command fails [which it will tbh 💡]
set -e

# Color definitions -------------------------------------------------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color
# -------------------------------------------------------------------------------

# functions ---------------------------------------------------------------------
check_dependency() {
  if ! command -v $1 &> /dev/null; then
    echo -e "${RED}Error: $1 is not installed. Please install $1 first.${NC}"
    exit 1
  fi
}

check_required_file() {
  if [ ! -f "$1" ]; then
    echo -e "${RED}Error: Missing required file: $1${NC}"
    exit 2
  fi
}
#  ------------------------------------------------------------------------------

# check ruby dependency
check_dependency ruby

# check files
check_required_file "Gemfile"
check_required_file "lumen.rb"

# Install bundler if not exists
if ! gem list bundler -i > /dev/null; then
  echo -e "${YELLOW}Installing Bundler...${NC}"
  gem install bundler
else
  echo -e "${GREEN}Bundler already installed ✓${NC}"
fi

# Install gem dependencies if needed
if ! bundle check &> /dev/null; then
  echo -e "${YELLOW}Installing dependencies...${NC}"
  bundle install
else
  echo -e "${GREEN}All dependencies are up to date ✓${NC}"
fi

# Run the Ruby script with clean output
echo -e "\n${GREEN}Starting Lumen...${NC}"
echo -e "${YELLOW}✨ May the light guide you! ✨${NC}"

echo -e "\n${YELLOW}=================================================${NC}"
echo -e "${GREEN}>>>>>>>> LUMEN OUTPUT STARTING BELOW <<<<<<<<${NC}"
echo -e "${YELLOW}=================================================${NC}\n"

bundle exec ruby lumen.rb || {
  echo -e "\n${RED}⚠️  Lumen execution failed ⚠️${NC}"
  exit 3
}

echo -e "\n${YELLOW}=================================================${NC}"
echo -e "${GREEN}<<<<<<<< LUMEN OUTPUT COMPLETED FINSH >>>>>>>>${NC}"
echo -e "${YELLOW}=================================================${NC}\n"

exit 0