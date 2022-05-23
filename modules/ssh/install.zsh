#!/usr/bin/env zsh

echo "testing if ssh folder exists"

if [ -d "~/.ssh" ]; then
	echo "ssh folder found"
else
	echo "no ssh folder found"
	echo -n "🤖 “create ? (y/n)” > "
	read method
	[[ $method == n* ]] &&  echo "🤖 “Ok, bye”" && return 0

	echo "creating ssh key"
	ssh-keygen -t ed25519 -C "sebastien.balayn@gmail.com"

	echo "starting ssh agent"
	eval "$(ssh-agent -s)"

	# adding ssh key to ssh-agent
	# brackets are for echoing only one block of text
	# echo -e allows tabs to be respected
	echo "adding load of ssh key into ssh-agent"
	{
		echo -e "Host *"
		echo -e "\tAddKeysToAgent yes"
		# only use if passphrase
		# echo -e "\tUseKeychain yes"
		echo -e "\tIdentityFile ~/.ssh/id_ed25519"
	} > test.txt

	echo "adding ssh key to ssh-agent"
	# add -K if passphrase
	ssh-add ~/.ssh/id_ed25519

	echo "copying ssh key to clipboard"
	pbcopy < ~/.ssh/id_ed25519.pub

	echo "opening github so we paste the key"
	open https://github.com/settings/ssh/new
fi
