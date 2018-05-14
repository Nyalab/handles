#!/usr/bin/env zsh

. $HANDLES_PATH/src/helpers.sh

brew install git
brew install hub

ln -sf $HANDLES_PATH/modules/git/gitconfig $HOME/.gitconfig

echo "Creating a GitHub token:"
echo "  Login to GitHub to get a token & paste it (ENTER to skip)"
open "https://github.com/settings/tokens/new"
echo -n "🤖 “The message is a request for information” > "
read gh_token
if [ "$gh_token" != "" ]; then
  echo $gh_token | tee $HOME/.github_token
fi

# display a barchart for most touched files
# https://github.com/jez/git-heatmap
npm install -g https://github.com/jez/bars.git
brew install jez/formulae/git-heatmap

# display a summary of your past commits
# https://github.com/kamranahmedse/git-standup
npm install -g git-standup
