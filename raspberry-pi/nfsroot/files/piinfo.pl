#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

my $cpuinfo=`cat /proc/cpuinfo`;
my $eth0=`ip addr show eth0`;
my $otp=`sudo vcgencmd otp_dump`;

my %hw=();
foreach(qw(Hardware Revision Serial Model)) {
	$hw{$_}=$1 if($cpuinfo=~/$_\s+:\s+(.+)/m);
}
$hw{Serial}=~s/^0+//;

my %e0=();
$e0{IPv4}=$1 if($eth0=~/inet ([^\s]+) /m);
$e0{HWAddr}=$1 if($eth0=~m!link/ether ([^\s]+) !m);

my $usbboot=$1 if($otp=~/^17:(.+)$/m);

say "Model:  $hw{Model}($hw{Revision})";
say "SoC:    $hw{Hardware}";
say "Serial: $hw{Serial}";
say "IPv4:   $e0{IPv4}";
say "HWAddr: $e0{HWAddr}";

if($usbboot eq '3020000a') {
	say "program_usb_boot_mode=1 ENABLE";
} else {
	say "program_usb_boot_mode=1 DISABLE";
}
