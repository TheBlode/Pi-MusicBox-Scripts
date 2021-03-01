#!/bin/bash
######################################
# Custom Shutdown Script
# by The_Blode
# 01/02/20
# Allows users to schedule a system to shutdown
######################################
# Get number of minutes before shutdown
echo "======================================"
echo "Welcome to Martin's Shutdown Script!"
echo "======================================"
echo "Please enter the number of minutes before system shutdown."
read minutes

# Wait for number of seconds
echo "======================================"
echo "System will shutdown in $minutes minutes"
echo "======================================"
sleep "$minutes"m

# Shutdown
shutdown -h -P now