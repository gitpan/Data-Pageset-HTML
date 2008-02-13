package Data::Pageset::HTML;

###########################################################################
# Data::Pageset::HTML
# Mark Grimes
# $Id: NAMESPACE.pm,v 1.3 2006/11/29 02:40:22 mgrimes Exp $
#
# Extension to the Data::Pageset module that simplifies the creation of HTML page navigation
# Copyright (c) 2008 Mark Grimes (mgrimes@cpan.org).
# All rights reserved. This program is free software; you can redistribute
# it and/or modify it under the same terms as Perl itself.
#
# Thanks!
#
###########################################################################

use strict;
use warnings;

use base 'Data::Pageset';
our $VERSION = '0.11';

sub html {
    my $self             = shift;
    my $frmt             = shift;
    my $frmt_for_current = shift || _strip_link_from_format($frmt);

    my $txt;

    if ( $self->current_page > 1 ) {
        $txt .= _html_printf( $frmt, $self->current_page - 1, '&lt;&lt;' );
    }
    if ( $self->previous_set ) {
        if ( $self->previous_set < _min( @{ $self->pages_in_set } ) ) {
            my $chunk = $frmt;
            $txt .= _html_printf( $frmt, 1 );
            $txt .= _html_printf( $frmt, $self->previous_set, '...' );
        }
    }
    for my $num ( @{ $self->pages_in_set } ) {
        if ( $num == $self->current_page ) {
            $txt .= _html_printf( $frmt_for_current, $num );
        } else {
            $txt .= _html_printf( $frmt, $num );
        }
    }
    if ( $self->next_set ) {
        if ( $self->next_set > _max( @{ $self->pages_in_set } ) ) {
            $txt .= _html_printf( $frmt, $self->next_set, '...' );
            $txt .= _html_printf( $frmt, $self->last_page );
        }
    }
    if ( $self->current_page < $self->last_page ) {
        $txt .= _html_printf( $frmt, $self->current_page + 1, '&gt;&gt;' );
    }

    return $txt;
}

sub _strip_link_from_format {
    my $frmt = shift;

    $frmt =~ s{<a[^>]*?>}{};           # strip the first <a> link
    $frmt =~ s{(.*)</a[^>]*?>}{$1};    # strip the last </a> link

    return $frmt;
}

sub _html_printf {
    my $frmt = shift;
    my $p    = shift;
    my $l    = shift || $p;         # default for $a is current page num

    $frmt =~ s{ \%p }{$p}gx;        # substitute the page number for %p
    $frmt =~ s{ \%a }{$l}gx;        # substitute the text for %a

    return $frmt;
}

sub _min {  ## no critic
    my $min = shift;
    for (@_) {
        $min = $_ if $_ < $min;
    }
    return $min;
}

sub _max {  ## no critic
    my $max = shift;
    for (@_) {
        $max = $_ if $_ > $max;
    }
    return $max;
}

1;

__END__

=head1 NAME

Data::Pageset::HTML - Subclass of C<Data::Pageset> that generates html, text,
etc. for page navigation 

=head1 SYNOPSIS

  ### In the Controller part of you MVC
  # Create the pager as you would normally with Data::Pageset
  use Data::Pageset::HTML;
  my $pager = Data::Pageset::HTML->new( {
        total_entries    => 100,
        entries_per_page => 10,
        current_page     => 1,
        pages_per_set    => 5,
        mode             => 'slider',
  } );

  ### In the view part of your MVC
  # Basic usage:
  my $text = $pager->html( '<a href="q?page=%p">%a</a>' );
  # $text is html "<< 1 ... 3 4 5 6 7 ... 10 >>" with appropriate links
  # A bit more control over the appearence of the current page:
  my $text = $pager->html( '<a href="q?page=%p">%a</a>', '[%a]' );
  # $text is html "<< 1 ... 3 4 [5] 6 7 ... 10 >>" with appropriate links

  ### As part of larger framework
  # In a TT template:
  [% pager.html( '<a href="q?page=%p">%a</a>' ) %]
  # In a Mason template:
  <% $pager->html( '<a href="q?page=%p">%a</a>' ) %>

=head1 DESCRIPTION


=head1 METHODS

C<Data::Pageset::HTML> add the following method to C<Data::Pageset>. The
constructor and all of C<Data::Pageset>s methods continue to function as
normal.

=over 4

=item html( $link_format )

=item html( $link_format, $current_page_format )

  my $text = $pager->html( '<a href="q?page=%p">%a</a>' );
  my $text = $pager->html( '<a href="q?page=%p">%a</a>', '[%a]' );

Produces the text necessary to implement page navigation. Most often this
will be used to create a links to pages within your web app. The two special
character codes C<%p> and C<%a> will be substituted with the page number and
the link text, respectively. C<%a> will usually also be the page number, but
sometimes it could be "<<", ">>", or "...".

Rather than code this in TT or Mason or (even worse) by hand,
C<Data::Pageset::HTML> replaces all of this:

    ## TT template:
    [% IF pager.current_page > 1 %]
        <a href="display?page=[% pager.current_page - 1 %]">&lt;&lt;</a>
    [% END %]
    [% FOREACH num = [pager.first_page .. pager.last_page] %]
    [% IF num == pager.current_page %][[% num %]]
    [% ELSE %]<a href="display?page=[% num %]">[[% num %]]</a>[% END %]
    [% END %]
    [% IF pager.current_page < pager.last_page %]
        <a href="display?page=[% pager.last_page %]">&gt;&gt;</a>
    [% END %]

with this:

    [% pager.html( '<a href="display?page=%p">%a</a>', '[%a]' ) %]

And you get even more goodness from C<Data::Pageset> limiting the pages
displayed to something reasonable if you are dealing with a large number
of pages.

=back

=head1 TODO

In this release, there is limited ability to customize the page navigation.
I plan to add the ability to customize the following:

=over 4

=item * Option to not display the first/last pages if they aren't part of
        current page set

=item * Option to not display the link to the prior/next page set (assuming
        it exists)

=item * Ability to customize the look of "move back/forward" links
        (currently only << and >> are supported) or turn them off completely

=item * Ability to customize the look of the prior/next page sets 
        (currently only "..." is supported)

=item * Ability to specify the separators between links (ie, enable
        "1 | 2 | 3 | 4" type pagers)

=back

This module is a work in progress and suggestions are welcome.

=head1 SEE ALSO

C<Data::Pageset>, C<Class::DBI::Pageset>, C<Data::Page> 

=head1 BUGS

Please report any bugs or suggestions at 
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Pageset-HTML>

=head1 AUTHOR

Mark Grimes, E<lt>mgrimes@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Mark Grimes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
