# Crawler for getting ATC codes from the WHO Collaboration Center
# Version 1.0, 10-Aug-2014
#######################################

$version="1.0";

$|=1;             # flush immediately

# use lib "bin";      # to search for local package
use LWP::RobotUA; # Loads LWP robot classes
$mailrecipient='reich@ohdsi.org';


# 1. Open logs

$Logfile=">>Log\\ATCRobot.log";
$Errorfile=">>Log\\ATCErrors.log";
unless (open Errorfile) {
    die("Can't open error log $Errorfile: $!"); # can't ferror() this
}
open Logfile or ferror("Can't open logfile $Logfile: $!");

# 2. Prepare robot

$browser = LWP::RobotUA->new("ATC Robot $version", $mailrecipient);
$browser->delay(.1/20); # 300 ms delay
geturl("http://www.whocc.no/atc_ddd_index"); # test robot

$maxerrors=20; # countdown $maxerors, at 0 we pull the plug

# 3. Read existing ones, so if it crashes we can continue where we left off

%atc=(); # create hash with all codes and deescriptions
$atccodes="ATC-Codes.txt";
open atccodes or ferror("Can't open $atccodes: $!");
<atccodes>; # skip header row
$count=0;
while (<atccodes>) {
    chomp;
    @fields=split(/\t/);
    $code=shift(@fields); $description=shift(@fields);
	$atc{$code}=$description;
}
# print "$_ $atc{$_}\n" for (keys %atc);
close atccodes;

# 4. All main pages (full letter pages) and dig from there

@atctops=(
	"A", "B", "C", "D", "G", "H", "J", "L", "M", "N", "P", "R", "S", "V"
);

$WriteATC=">>".$atccodes;
open WriteATC or ferror("Can't open file for adding lines: $!");

# 5. Sift through all letters
foreach $atctop (@atctops) {
	read_and_dive($atctop);
}

# print "$_ $atc{$_}\n" for (keys %atc);


# 6. Tidy up

close WriteATC; 
return;

#############################################################

# recursive crawling
sub read_and_dive { # ($atctop) 
    my $current=shift; # code to investigate
	my $url="http://www.whocc.no/atc_ddd_index/?code=$current&showdescription=yes"; # create url
	warn "Working on code $current";
    my $body=geturl($url) or ferror("Unable to get page: $!");
	while ($body =~ /<a href="\.\/\?code=(\w+)(&showdescription=(no|yes))?">(.+?)<\/a>/ig) {
        $code=$1; $description=$4;
		$description=~s/<.*?>//g; # remove html tags
# 		warn "Current $current, Code $code - $description";
		next if $current=~/^$code/; # we already came from there
		next if $description=~/hide text from guidelines/i;
		if (exists $atc{$code}) {
#			warn "Code $code - $description exists already";
		}
		else {
			$atc{$code}=$description; # register
			print WriteATC "$code\t$description\n";
			warn "Found new code $code - $description";
		}
		if (length($code)<7) { # dive into tree and find codes if code is shorter than 7
			warn "Going into $code - $description";
			logerror("Can't open $url") unless(read_and_dive($code));
		}
	}
	return(1); # done
}

sub ferror { # ("error message to log"), die at the end
    $message=shift;
    print Errorfile timestamp(), $message, "\n";
    die $message;
    return;
}

sub logmessage { # ("message to log")
    $message=shift;
    print Logfile timestamp(), $message, "\n";
    return;
}

sub logerror { # ("error message to log")
    $message=shift;
    unless (--$maxerrors) { # too many soft errors
        ferror("Maxerrors exhaustet: ".$message);
    }
    print Errorfile timestamp(), $message, "\n";
    return;
}

sub timestamp { # ()
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    $year+=1900; $mon++;
    return "$mday.$mon.$year, $hour:$min:$sec: ";
}

sub geturl { # ($url);
    $url=shift;
    my $response=$browser->get($url);
    ferror("URL $url returns ".$response->status_line) unless ($response->is_success);
    ferror("Content type not HTML in URL $url") unless $response->content_type eq 'text/html';
    return($response->decoded_content);
}

