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

# Define working directory
my $working_directory = getcwd();

# Load config
my $file = "$working_directory/config.txt";

# Open file handle
open my $info, $file or die "Could not open $file: $!";

while(my $line = <$info>) {
    # Fetch email address
    if ($line =~ m/music_path=/) {
        # Store email address
        $path = $line;

        # Format result
        $path =~ s/music_path=//gi;
    }
}

# Close file handle
close $info;

# Run the main loop forever until the device is rebooted
while (1 eq 1) {
    # If something is not playing...search for something new to play
    while ($playing eq 0) {
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
                    debug("Listening to $random_folder");
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

    # Debug if song is playing
    if ($debug eq 1) {
        if ($playing == 1) {
            debug("Something is playing.");
        } else {
            debug("Nothing is playing.");
        }
    }

    if ($playing eq 0) {
        if ($debug eq 1) {
            debug("Waiting for a little while until the next loop.");
        }

        # Sleep
        sleep(10);
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