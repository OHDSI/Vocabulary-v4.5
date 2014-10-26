#!/usr/bin/perl
# Automatic loader for Read-17 vocabulary 
# Version 1.0, 26-Aug-2014

use warnings;
use strict;
use DBI;

my $dbh = DBI->connect('DBI:Oracle:omop', 'dev', '123', {AutoCommit => 1})
			or die "Couldn't connect to database: " . DBI->errstr;

$dbh->do('create table concept_ancestor_stage as select * from concept_ancestor where 1=0')
or die "Couldn't prepare statement: " . $dbh->errstr;
$dbh->do('create table concept_ancestor_stage as select * from concept_ancestor where 1=0')
or die "Couldn't prepare statement: " . $dbh->errstr;
$dbh->do('create table new_gen_new as select * from concept_ancestor where 1=0')
or die "Couldn't prepare statement: " . $dbh->errstr;
$dbh->do('create table new_gen_existing as select * from concept_ancestor where 1=0')
or die "Couldn't prepare statement: " . $dbh->errstr;
$dbh->do('create table new_tree as select * from concept_ancestor where 1=0')
or die "Couldn't prepare statement: " . $dbh->errstr;

$dbh->finish;
$dbh->disconnect;


die;
