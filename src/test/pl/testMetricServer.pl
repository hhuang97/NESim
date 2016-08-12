#!/usr/bin/perl

use strict;

use IO::Socket;
use FileHandle;

my $DEBUG_ME = 0;

my $host = "localhost";
my $port = 2690;

# create a tcp connection to the specified host and port
my $handle = IO::Socket::INET->new(Proto  => "tcp",
                                PeerAddr  => $host,
                                PeerPort  => $port)
       or die "can't connect to port $port on $host: $!";

$handle->autoflush(1);              # so output gets there right away
print STDERR "[Connected to $host:$port]\n";


my $firstString = "ORG#International Business Machines";
my $secondString = "ORG#IBM";

&SendTo($handle, \$firstString);
&SendTo($handle, \$secondString);

my ($answer, $reason);

$answer = &ReceiveFrom($handle);
$reason = &ReceiveFrom($handle);

print "second answer: $answer\n";
print "second reason: $reason\n";

&sendEndSignal($handle);

close $handle or die "Can't close handle...\n";


sub SendTo #server, msg
{
  my $serverSock = shift;
  my $msgToServerRef = shift;
  send $serverSock, pack("N", length $$msgToServerRef), 0;
  print $serverSock $$msgToServerRef;
}

sub sendEndSignal
{
  my $serverSock = shift;

# tell client not to wait on any more input
  send $serverSock, pack("N", 0), 0;
}


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

  $received = 0;
  $message = "";

  while ($received < $length)
  {
    recv $socket, $msg, $length - $received, 0;
    $received += length $msg;
    $message .= $msg;
  }

  return $message;
}

