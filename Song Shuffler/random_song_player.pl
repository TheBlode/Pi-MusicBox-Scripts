# ====================================
# Random Music Player
# Written by The_Blode
# 10/06/20
# ====================================
use Cwd;

# Set variable to check if something is playing
my $playing = 0;
my $valid_folder = 0;
my $random_folder = "";
my $datestring = "";
my $debug = 0;
my $path = "";
my $breaks = "";
my $break_message = "";
my $break_interval = 1;
my $alarm_active = 0;
my $play_music = 1;
my $alarm_on = 0;

# Run the main loop forever until the device is rebooted
while (1 eq 1) {
    # Parse runtime options and search for changes dynamically
    # Define working directory
    my $working_directory = getcwd();

    # Load config
    my $file = "$working_directory/config.txt";
                        
    # Open file handle
    open my $info, $file or die "Could not open $file: $!";

    while(my $line = <$info>) {
        # Fetch music path address
        if ($line =~ m/music_path=/) {
            # Store music path address
            $path = $line;

            # Format result
            $path =~ s/music_path=//gi;
            chomp($path);
        }

        # Fetch break message path
        if ($line =~ m/break_time_message=/) {
            # Store break flag
            $breaks = $line;

            # Format result
            $breaks =~ s/break_time_message=//gi;
            chomp($breaks);
        }

        # If breaks are enabled, load break message path
        if ($breaks == "1") {
            # Fetch break message path
            if ($line =~ m/break_message_path=/) {
                # Store break path address
                $break_message = $line;

                # Format result
                $break_message =~ s/break_message_path=//gi;
                chomp($break_message);
            }

            # Fetch break interval
            if ($line =~ m/break_time_interval=/) {
                # Store break time interval
                $break_interval = $line;

                # Format result
                $break_interval =~ s/break_time_interval=//gi;
                chomp($break_interval);
            }
        }

        # If alarms is enabled, load break variable into program
        if ($line =~ m/alarm_mode=/) {
            # Store alarm flag
            $alarm_active = $line;

            # Format result
            $alarm_active =~ s/alarm_mode=//gi;
            chomp($alarm_active);
        }

        # If alarms is enabled, load break variable into program
        if ($alarm_active == 1) {
            # Fetch alarm time
            if ($line =~ m/alarm_time=/) {
                # Store break path address
                $alarm_time = $line;

                # Format result
                $alarm_time =~ s/alarm_time=//gi;
                chomp($alarm_time);
            }

            # Fetch alarm begin time
            if ($line =~ m/alarm_begin_time=/) {
                # Store break path address
                $alarm_begin_time = $line;

                # Format result
                $alarm_begin_time =~ s/alarm_begin_time=//gi;
                chomp($alarm_begin_time);
            }
        }

        # Fetch play music flag
        if ($line =~ m/play_music=/) {
            # Store break flag
            $play_music = $line;

            # Format result
            $play_music =~ s/play_music=//gi;
            chomp($play_music);
        }
    }

    # Close file handle
    close $info;

    # If something is not playing...search for something new to play
    while ($playing eq 0 && $alarm_on eq 0 && $play_music eq 1) {
        # If valid folder found...exit
        if ($valid_folder eq 0) {
            # Import time module
            use POSIX qw(strftime);
            # Generate a date and time string (in the format of Martin's Master Task Logger)
            $datestring = strftime "%d-%m-%Y_%H_%M-%S", localtime;

            # Gather music folders
            # Exit if directory not found
            die "Please specify which directory to search" 
                unless -d $path;

            # Open directory handle
            opendir(my $dir, $path);

            # Initialise main folders array
            my @main_folders = "";

            # Find music directories and store in array
            while (my $entry = readdir $dir) {
                push(@main_folders, $entry) 
            }

            # Close directory handle
            closedir $dir;

            # Initialise sub folders array
            my @sub_folders = "";

            # Find sub directories
            foreach my $n (@main_folders) {
                # Define new path
                my $path = "$path$n/";

                # Open directory handle
                opendir(my $dir, $path);

                # Find music directories
                while (my $entry = readdir $dir) {
                    # Skip these folders
                    # Push to sub folders
                    if (index($entry, ".") != -1) {
                        # Skip
                    } elsif (index($entry, "..") != -1) {
                        # Skip
                    } elsif (index($entry, "mp3") != -1) {
                        # Skip
                    } else {
                        # Push to sub folder array
                        push(@sub_folders, "$path$entry");
                    }
                }

                # Close directory handle
                closedir $dir;
            }

            # Generate random folder
            $random_folder = splice(@sub_folders, rand @sub_folders, 1);

            # Check if random folder is valid
            if (index($random_folder, "/.") != -1) {
                # Skip
            } elsif (index($random_folder, "..") != -1) {
                # Skip
            } elsif (index($random_folder, "//") != -1) {
                # Skip
            } else {
                # Valid folder found
                $valid_folder = 1;

                if ($debug eq 1) {
                    debug("=======================");
                    debug("Listening to $random_folder");
                    debug("=======================");
                    debug("\n");
                }

                # Open directory handle
                opendir(my $dir, $random_folder);

                # Initialise folder tracks array
                my @folder_tracks = "";

                # Find music directories and store in array
                while (my $entry = readdir $dir) {
                    if (index($entry, "mp3") != -1) {
                        push(@folder_tracks, "$random_folder/$entry");
                    }
                }

                # Close directory handle
                closedir $dir;

                # Clear playlist
                `mpc clear`;
                # Get a random track from the album
                @song_array = shuffle(@folder_tracks);

                # Play song
                `mpc add "file://$song_array[0]"`;

                # Generate output
                $output = "$datestring: $song_array[0]\n";

                # Open file for writing
                open(my $fh, ">>", "/root/songs_listened_to.txt") or die "Could not open file '$file' $!";

                # Output to file
                print $fh $output;

                # Close file handle
                close $fh;

                # Play album
                `mpc play`;
                
                # Set playing flag
                $playing = 1;
            }
        }
    }

    # Unset valid folder flag
    $valid_folder = 0;

    # Check if something is playing
    my @mpc = `mpc`;

    # Check mpc command to see if anything is playing
    foreach my $n (@mpc) {
        # If we're playing something...do nothing
        if (index($n, "playing") != -1) {
            $playing = 1;
            last;
        } else {
            $playing = 0;
        }
    }

    # Check if it's break time
    # Grab current minute
    my ($seconds, $minute) = gmtime(time);
    my $result = $minute % $break_interval;

    if ($result == 0 && $alarm_active == 0 && $breaks == 1) {
        if ($debug eq 1) {
            debug("=======================");
            debug("It's break time!");
            debug("=======================");
            debug("\n");
        }

        # Play break message
        playBreakMessage();

        # Sleep for 60 seconds
        sleep(60);
    }

    # Debug if song is playing
    if ($debug eq 1) {
        if ($playing == 1) {
            debug("=======================");
            debug("Something is playing.");
            debug("=======================");
            debug("\n");
        } else {
            debug("=======================");
            debug("Nothing is playing.");
            debug("=======================");
            debug("\n");
        }
    }

    if ($playing eq 0) {
        if ($debug eq 1) {
            debug("=======================");
            debug("Waiting for a little while until the next loop.");
            debug("=======================");
            debug("\n");
        }

        # Sleep
        sleep(10);
    }

    # Check if the alarm is active
    if ($alarm_active == 1) {
        if ($debug eq 1) {
            debug("=======================");
            debug("Alarm mode is active.");
            debug("=======================");
            debug("\n");
        }

        # Get time
        my ($seconds, $minute, $hour) = gmtime(time);
        my $minute_as_int = $minute + 0;
        my $concat_time = "";

        if ($minute_as_int < 10) {
            $concat_time = $hour . "0" . $minute;
        } else {
            $concat_time = $hour . $minute;
        }

        # Convert to integer
        $concat_time = $concat_time + 0;

        if ($concat_time < $alarm_time || $concat_time > $alarm_begin_time) {
            $alarm_on = 1;
            if ($debug eq 1) {
                debug("=======================");
                debug("Alarm is active");
                debug("=======================");
                debug("\n");
            }
        } else {
            $alarm_on = 0;
            if ($debug eq 1) {
                debug("=======================");
                debug("Alarm is not active");
                debug("=======================");
                debug("\n");
            }
        }
    }
}

# Function to output debug
sub debug() {
    # Grab input
    $input = shift;

    # Print output
    print "$input\n";
}

# Function to shuffle array
sub shuffle(@) {
    my @a=\(@_);
    my $n;
    my $i=@_;
    map {
        $n = rand($i--);
        (${$a[$n]}, $a[$n] = $a[$i])[0];
    } @_;
}

# Function to play the break message
sub playBreakMessage() {
    # Clear playlist
    `mpc clear`;

    # Add break message to the queue
    `mpc add "file://$break_message"`;

    # Play break message
    `mpc play`;
}