#!/usr/bin/perl

use warnings;
use strict;

open CODE, '<', $ARGV[0];
open BIN, '>:raw', $ARGV[1];

my @bin;

while(<CODE>)
{
    my $loc = $_;
    $loc =~ s/^\s+|\s+$//g;
    my @ops = split(' ', $loc);

    my @out;

    if($ops[0] eq 'mov'){
	push(@out, ord('='));
    }elsif($ops[0] eq 'add'){
	push(@out, ord('+'));
    }elsif($ops[0] eq 'sub'){
	push(@out, ord('-'));
    }

    push(@out, &getCase($loc));
    push(@out, &getArgs($loc));

    push(@out, (0) x (4 - @out));
    push(@bin, @out);
}

for my $i(0..$#bin)
{
    if($bin[$i] =~ m/^0x|\#/){
	$bin[$i] =~ s/0x|\#//g;	
	$bin[$i] = hex($bin[$i]);
    }
    
    print BIN pack('s<', $bin[$i]);
}

sub getCase
{
    my $loc = $_[0];
    my @op = split(" ", $loc);
    if($op[1] =~ m/^r[0-9A-Fa-f]/ && $op[2] =~ m/^[0-9A-Fa-f\#]/){
	return 0;
    }elsif($op[1] =~ m/^\[[0-9A-Fa-fx#]+\]/ && $op[2] =~ m/^[0-9A-Fa-f\#]/){
	return 1;
    }elsif($op[1] =~ m/^r[0-9A-Fa-f]/ && $op[2] =~ m/^\[[0-9A-Fa-fx#]+\]/){
	return 2;
    }elsif($op[1] =~ m/^r[0-9A-Fa-f]/ && $op[2] =~ m/^r[0-9A-Fa-f]/){
	return 3;
    }elsif($op[1] =~ m/^\[[0-9A-Fa-fx#]+\]/ && $op[2] =~ m/^r[0-9A-Fa-f]/){
	return 4;
    }elsif($op[1] =~ m/^\[r[0-9A-Fa-f]\]/ && $op[2] =~ m/^[0-9A-Fa-f\#]/){
	return 5;
    }elsif($op[1] =~ m/^\[r[0-9A-Fa-f]\]/ && $op[2] =~ m/^r/){
	return 6;
    }elsif($op[1] =~ m/^r/ && $op[2] =~ m/^\[/){
	return 7;
    }else{
	die "Syntax Error!";
    }
}

sub getArgs
{
    my $loc = $_[0];
    my @op = split(" ", $loc);
    my @args;
    shift(@op);
    
    foreach(@op)
    {
	if($_ =~ m/^r/){
	    $_ =~ s/[r\,]//g;
	    push(@args, $_);
	}elsif($_ =~ m/^\[|,/){
	    $_ =~ s/\[|\]|,|r//g;
	    push(@args, $_);
	}elsif($_ =~ m/[0-9A-Fa-f\#]/){
	    $_ =~ s/,//g;
	    push(@args, $_);
	}
    }

    return @args;
}
