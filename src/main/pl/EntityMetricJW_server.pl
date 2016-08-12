#!/usr/bin/perl

##################################################
# This code is almost identical to the code for the
# charniak server
##################################################

$MAXCHAR = 799;
$MAXWORD = 400;

my $script_home = "/home/roth/cogcomp/quangdo2/EntityMetricJW/";

$command = "$script_home/EntityMetricJW_script";
$endProtocol = "\n";

$TIMEOUT = 60;
$PORT = 2690;

$PORT = $ARGV[0] if (scalar(@ARGV) > 0);

use Expect;

#create main program that will be communicating throught pipe.
$main = NewExpect($command);

sub NewExpect {
    my $command = shift;
    my $main;

    print "[Initializing...]\n";

    $main = new Expect();
    $main->raw_pty(1);     # no local echo
    $main->log_stdout(0);  # no echo
    $main->spawn($command) or die "Cannot start: $command\n";

    #$main->send("PER#Bush----PER#Bush\n");  #send input to main program
    #@res = $main->expect(undef,$endProtocol);  # read output from main program
    #print STDERR @res, "\n";

    print "[Done initializing.]\n";

    return $main;
}

#server initialization matter
use IO::Socket;
use Net::hostent;               # for OO version of gethostbyaddr

$server = IO::Socket::INET->new( Proto     => 'tcp',
                                 LocalPort => $PORT,
                                 Listen    => SOMAXCONN,
                                 Reuse     => 1);

die "Can't setup server: $!\n" unless $server;
#end server initialization

#set autoflush
$old_handle = select(STDOUT);
$| = 1;
select($old_handle);
$old_handle = select(STDERR);
$| = 1;
select($old_handle);

print "[Server $0 accepting clients]\n";
print "\n";

%cache = ();

while ($client = $server->accept()) {
    $main->expect(0);  # flush old stuff if any
    $main->clear_accum();  # clear buffer

    $client->autoflush(1);
    $clientinfo = gethostbyaddr($client->peeraddr);
    if (defined($clientinfo)) {
	$clientname = ($clientinfo->name || $client->peerhost);
    } else {
	$clientname = $client->peerhost;
    }
    my $now = localtime time;
    print "[Connect from $clientname - $now]\n";

    &RunClient($client);
    shutdown($client,3);
    close($client);
    print STDERR "[Connection closed from $clientname]\n";
    print "\n";
}

$main->hard_close();

sub ReceiveFrom #($socket)
{
  my($socket) = shift;

  my($length, $char, $msg, $message, $received);

  $received = 0;
  $message = "";

  while ($received < 4)
  {
    recv $socket, $msg, 4 - $received, 0;
    $received += length $msg;
    $message .= $msg;
  }

  $length = unpack("N", $message);
  print "Length = $length\n";

  $received = 0;
  $message = "";

  while ($received < $length)
  {
    recv $socket, $msg, $length - $received, 0;
    $received += length $msg;
    $message .= $msg;
  }
  print "Message = $message\n";

  return $message;
}

sub SendTo #server, msg
{
  my $serverSock = shift;
  my $msgToServerRef = shift;
  send $serverSock, pack("N", length $$msgToServerRef), 0;
  print $serverSock $$msgToServerRef;
}


sub RunClient {
    my $client = shift;
    my $output = "";
    my @res;
    my $timeout;

    my $sent = "";
    my $received = 0;
    my $msg = "";

    my $name1 = "";
    my $name2 = "";

    $name1 = &ReceiveFrom($client);
    $name2 = &ReceiveFrom($client);

    $msg = $name1."----".$name2."\n";

    $main->send("$msg");
    my ($answer, $reason);
    
    #$timeout = $res[1];
    #$out = $res[3];
    if ($timeout) { # some problem, restart
	print "Time out!\n";
	$output = "\n\n";  # output blank
	print "Restart...\n";
	$main->hard_close();
	$main = NewExpect($command);
    } 
    else 
    {
	#$output = "$out\n";
	#if ($out =~ /^\s*$/) {
        #  $numBlank = 1;
        #}
	#else {
        #  $numBlank = 0;
        #}
	#normal output should end with 2 blank lines.
	
        $numBlank = 0;
        my $i = 0;
	while ($numBlank < 2) 
	{
	    @res = $main->expect($TIMEOUT,$endProtocol);  # read output from main program
	    $timeout = $res[1];
	    $out = $res[3];
	    if ($timeout) 
	    { # parser possibly gets stuck, restart it.
		print "Time out when reading output!\n";
		$output = "\n\n";  # output blank
		print "Restart...\n";
		$main->hard_close();
		$main = NewExpect($command);
		last;
	    } 
	    else 
	    {
                $numBlank = 0;
                if ($i == 0) {
                  $answer = $out;
                }
                elsif ($i == 1) {
                  $reason = $out;
                }
                elsif ($i == 2) {
                  $numBlank = 3;
                  last;
                }
                $i += 1;
	    }
	}
    }

    &SendTo($client, \$answer);
    &SendTo($client, \$reason);

    $main->expect(0);  # flush old stuff if any
    $main->clear_accum();  # clear buffer
}
