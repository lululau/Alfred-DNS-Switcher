#!/usr/bin/perl

use strict;
use YAML::Syck; 
use XML::Writer;
use Data::Dumper;

$YAML::Syck::ImplicitTyping = 1;

my $pattern = '.*';
my $config;
my $config_file = $ENV{'HOME'} . '/.dns_switcher_options.yaml';

unless ( -e $config_file ) {
	$config_file = 'default_dns_switcher_options.yaml';
} 

$config = LoadFile($config_file);

my $option_name = @ARGV[0];

my $use_sudo = $config->{'use_sudo'};

my $option = (grep { $_->{'name'} == $option_name } @{$config->{'options'}})[0];

my $servers = $option->{'servers'};

my $default_gw = `netstat -nr | grep default`;
chomp $default_gw;
$default_gw =~ s/.*?(\S+)$/$1/;
my $device = `networksetup -listnetworkserviceorder | grep "$default_gw"`;
chomp $device;
$device =~ s/.*\s(\S+),.*/$1/;

my $cmd = "networksetup -setdnsservers $device $servers";
$cmd = "sudo " . $cmd if $use_sudo;
system $cmd;

