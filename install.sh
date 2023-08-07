for program in "bnyro bfetch pkg gi"; do
	sudo cp $program /usr/local/bin
	sudo chmod +x /usr/local/bin/$program
done
