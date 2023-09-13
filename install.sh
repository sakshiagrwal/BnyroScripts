for program in $(find . -maxdepth 1 -type f -executable ! -name "*.*"); do
	sudo cp $program /usr/local/bin
	sudo chmod +x /usr/local/bin/$program
done
