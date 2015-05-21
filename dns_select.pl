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

if ( scalar(@ARGV) > 0 ) {
	$pattern = quotemeta(@ARGV[0]);
}

my @filtered = grep { $_->{'name'} =~ /$pattern/i } @{$config->{'options'}};

my $current = `cat /etc/resolv.conf | grep '^nameserver'`;
$current = join(" ", ($current =~ /(\S+)\n/g));

my $writer = XML::Writer->new();

$writer->startTag('items');
foreach my $option (@filtered) {
	$writer->startTag('item', "valid" => "yes", "arg" => $option->{'name'}, "uid" => $option->{'name'});
	$writer->startTag('title');
	$writer->characters($option->{'name'});
	$writer->characters(" (current selected)") if $current eq $option->{'servers'};
	$writer->endTag('title');
	$writer->endTag('item');
}
$writer->endTag('items');
$writer->end();
