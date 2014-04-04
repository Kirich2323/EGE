# Copyright © 2014 Darya D. Gornak 
# Licensed under GPL version 2 or later.
# http://github.com/dahin/EGE
package EGE::SQL::Table;

use strict;
use warnings;

sub new {
    my ($class, $fields) = @_;
    $fields or die;
    my $self = {
        fields => $fields,
        data => [],
        field_index => {},
    };
    my $i = 0;
    $self->{field_index}->{$_} = $i++ for @$fields;
    bless $self, $class;
    $self;
}

sub insert_row {
    my $self = shift;
    @_ == @{$self->{fields}}
        or die sprintf "Wrong column count %d != %d", scalar @_, scalar @{$self->{fields}};
    push @{$self->{data}}, \@_;
    $self;
}

sub insert_rows {
    my $self = shift;
    $self->insert_row(@$_) for @_;
    $self;
}

sub print_row { print join("\t", @{$_[0]}), "\n"; }

sub print {
    my $self = shift;
    print_row $_ for $self->{fields}, @{$self->{data}};
}

sub select {
    my ($self, $fields) = @_;
    my $result = EGE::SQL::Table->new($fields);
    my @indexes = map $self->{field_index}->{$_} // die("Unknown field $_"), @$fields;
    $result->{data} = [ map [ @$_[@indexes] ], @{$self->{data}} ];
    $result;
}

1;
