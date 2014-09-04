#!/usr/bin/perl

use warnings;
use strict;
use DBI;
use POSIX;
use Archive::Tar::Wrapper;

sub table_cols_query { 'SELECT COLUMN_NAME FROM ALL_TAB_COLUMNS WHERE OWNER = ? AND TABLE_NAME = ? ORDER BY COLUMN_ID' }

sub table_cols { [ map { $_->[0] } @{ shift->selectall_arrayref(table_cols_query, undef, shift, shift) } ] }

sub csv_line { map { "$_\n" } join ',', map { $_ ||= ''; s/[\",]/\\$&/g; $_ } map { @$_ } @_ }

sub all_vocabularies { map { $_->[0] } @{ shift->selectall_arrayref('SELECT * FROM VOCABULARY') } }

sub csv_dump {
    my ($dbh, $table) = @_;
    my $cols = table_cols $dbh, $dbh->{Username}, $table->{name};
    my $sth = $dbh->prepare($table->{query});
    $sth->execute(@{$table->{params}});
    my $dump = tmpnam;
    open my $fh, '>', $dump;
    print $fh csv_line $cols;
    while (my $line = $sth->fetch) {
	print $fh csv_line $line;
    }
    close $fh;
    return $dump;
}

do { print <<END
Usage:
./dump.pl \<user/pass\@host/sid\> \<output.tbz\> [vocabulary ids]
'vocabulary ids' is a comma-separated list of required vocabularies, omit the list in order to dump all available 
END
} and exit unless @ARGV;

die unless shift =~ /^(.+)\/(.+)\@(.+)\/(.+)$/;
my $dbh = DBI->connect(sprintf('dbi:Oracle:host=%s;sid=%s', $3, $4), $1, $2) or die;
my $output = shift or die;
my @vocabularies = split /,/, (shift or join ',', all_vocabularies $dbh);
my $placeholder = join ', ', split //, '?' x @vocabularies;

my $tar = new Archive::Tar::Wrapper;
do {
    my $dump = csv_dump $dbh, $_;
    $tar->add(sprintf('%s.csv', $_->{name}), $dump);
    unlink $dump;
} for
    {
	name => 'CONCEPT',
    	query => sprintf('SELECT * FROM CONCEPT WHERE VOCABULARY_ID IN (%s)', $placeholder),
	params => [ @vocabularies ],
    },
    {
	name => 'CONCEPT_RELATIONSHIP',
	query => sprintf('SELECT * FROM CONCEPT_RELATIONSHIP WHERE EXISTS (SELECT * FROM CONCEPT WHERE CONCEPT_ID_1 = CONCEPT_ID AND VOCABULARY_ID IN (%s)) AND EXISTS (SELECT * FROM CONCEPT WHERE CONCEPT_ID_2 = CONCEPT_ID AND VOCABULARY_ID IN (%s))', $placeholder, $placeholder),
	params => [ @vocabularies, @vocabularies ],
    },
    {
	name => 'SOURCE_TO_CONCEPT_MAP',
	query => sprintf('SELECT * FROM SOURCE_TO_CONCEPT_MAP WHERE SOURCE_VOCABULARY_ID IN (%s) AND TARGET_VOCABULARY_ID IN (%s)', $placeholder, $placeholder),
	params => [ @vocabularies, @vocabularies ],
    };
$tar->write($output, 1);
