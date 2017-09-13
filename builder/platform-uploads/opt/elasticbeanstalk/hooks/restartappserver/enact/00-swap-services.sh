BLUE_STATUS=`sudo systemctl is-active blue`
GREEN_STATUS=`sudo systemctl is-active green`

if [ $BLUE_STATUS == "active" ]; then
	echo "Blue is active, starting green service"

	if [ $GREEN_STATUS == "deactivating" ]; then
		echo "Green was in the process of deactivating, restarting"
		sudo systemctl kill green
	fi

	sudo systemctl start green

	echo "Green service started, sending SIGINT to blue service"
	sudo systemctl stop blue &
elif [[ $GREEN_STATUS == "active" ]]; then
	echo "Green is active, starting blue service"

	if [ $BLUE_STATUS == "deactivating" ]; then
		echo "Blue was in the process of deactivating, killing"
		sudo systemctl kill blue
	fi

	sudo systemctl start blue

	echo "Blue service started, sending SIGINT to green service"
	sudo systemctl stop green &
else
	echo "Neither service was active, starting blue service"
	# Start blue
	sudo systemctl restart blue
fi
