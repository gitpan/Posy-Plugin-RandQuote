package Posy::Plugin::RandQuote;
use strict;

=head1 NAME

Posy::Plugin::RandQuote - Posy plugin to give a random quote from a file.

=head1 VERSION

This describes version B<0.41> of Posy::Plugin::RandQuote.

=cut

our $VERSION = '0.41';

=head1 SYNOPSIS

    @plugins = qw(Posy::Core
	...
	Posy::Plugin::RandQuote));
    @entry_actions = qw(header
	    ...
	    parse_entry
	    rand_quote
	    render_entry
	    ...
	);

    And in the entry file:

    <pre>
    <!--quote(fortunes)-->
    </pre>

=head1 DESCRIPTION

Sticks a random quote from a file into the body of the entry.
This replaces a string in the format of <!--quote(I<filename>)-->
with a "quote" grabbed from the file, where quotes are defined
by text between $rand_quote_delim.

This looks for the quote-file first in the local (data) directory,
then relative to the top of the data directory, then in the local
HTML directory, then relative to the top of the HTML directory.

This creates a 'rand_quote' entry action, which should be placed after
'parse_entry' in the entry_action list and before 'render_entry'.  If you
are using the Posy::Plugin::ShortBody plugin, this should be placed after
'short_body' in the entry_action list, not before it.

=head2 Configuration

This expects configuration settings in the $self->{config} hash,
which, in the default Posy setup, can be defined in the main "config"
file in the data directory.

=over

=item B<rand_quote_delim>

The delimiter which defines quotes in the quote-file.
(default: "%\n", which is what is used in "fortune" data
files)

=back

=cut

=head1 OBJECT METHODS

Documentation for developers and those wishing to write plugins.

=head2 init

Do some initialization; make sure that default config values are set.

=cut
sub init {
    my $self = shift;
    $self->SUPER::init();

    # set defaults
    $self->{config}->{rand_quote_anchor} = qr{<!--\s*quote\(([./\w]+)\)\s*-->}
	if (!defined $self->{config}->{rand_quote_anchor});
    $self->{config}->{rand_quote_delim} = "%\n"
	if (!defined $self->{config}->{rand_quote_delim});
} # init

=head1 Entry Action Methods

Methods implementing per-entry actions.

=head2 rand_quote

$self->rand_quote($flow_state, $current_entry, $entry_state)

Alters $current_entry->{body} by adding a random quote
wherever the "rand_quote_anchor" string is in the body.

=cut
sub rand_quote {
    my $self = shift;
    my $flow_state = shift;
    my $current_entry = shift;
    my $entry_state = shift;

    my $body = $current_entry->{body};
  
    if ($body)
    {
	my $rq_reg = $self->{config}->{rand_quote_anchor};

	$body =~ s:$rq_reg:$self->_get_random_quote($1):ego;
	$current_entry->{body} = $body;
    }

    1;
} # rand_quote

=head1 Private Methods

=head2 _get_random_quote

Return the quote to be substituted from the given file.

=cut
sub _get_random_quote {
    my $self = shift;
    my $filename = shift;

    my $delim = $self->{config}->{rand_quote_delim};
    # look in the local data directory first
    my @path_split = split(/\//, $self->{path}->{cat_id});
    my $rand_file = File::Spec->catfile($self->{data_dir},
					@path_split, $filename);
    if (!open(FILE, $rand_file))
    {
	# look relative to the top data directory
	$rand_file = File::Spec->catfile($self->{data_dir}, $filename);
	if (!open(FILE, $rand_file))
	{
	    # look in local HTML directory
	    $rand_file = File::Spec->catfile(@path_split, $filename);
	    if (!open(FILE, $rand_file))
	    {
		# look with no alteration
		$rand_file = $filename;
		open(FILE, $rand_file)
		    or return "Can't open $rand_file: $!\n";
	    }
	}
    }

    my @phrases;
    {
	local $/ = $delim;
	chomp (@phrases = <FILE>);
    }

    my $phrase = $phrases[rand(@phrases)];

    return $phrase;
} # _get_random_quote

=head1 INSTALLATION

Installation needs will vary depending on the particular setup a person
has.

=head2 Administrator, Automatic

If you are the administrator of the system, then the dead simple method of
installing the modules is to use the CPAN or CPANPLUS system.

    cpanp -i Posy::Plugin::RandQuote

This will install this plugin in the usual places where modules get
installed when one is using CPAN(PLUS).

=head2 Administrator, By Hand

If you are the administrator of the system, but don't wish to use the
CPAN(PLUS) method, then this is for you.  Take the *.tar.gz file
and untar it in a suitable directory.

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

Or, if you're on a platform (like DOS or Windows) that doesn't like the
"./" notation, you can do this:

   perl Build.PL
   perl Build
   perl Build test
   perl Build install

=head2 User With Shell Access

If you are a user on a system, and don't have root/administrator access,
you need to install Posy somewhere other than the default place (since you
don't have access to it).  However, if you have shell access to the system,
then you can install it in your home directory.

Say your home directory is "/home/fred", and you want to install the
modules into a subdirectory called "perl".

Download the *.tar.gz file and untar it in a suitable directory.

    perl Build.PL --install_base /home/fred/perl
    ./Build
    ./Build test
    ./Build install

This will install the files underneath /home/fred/perl.

You will then need to make sure that you alter the PERL5LIB variable to
find the modules, and the PATH variable to find the scripts (posy_one,
posy_static).

Therefore you will need to change:
your path, to include /home/fred/perl/script (where the script will be)

	PATH=/home/fred/perl/script:${PATH}

the PERL5LIB variable to add /home/fred/perl/lib

	PERL5LIB=/home/fred/perl/lib:${PERL5LIB}

=head1 REQUIRES

    Posy
    Posy::Core

    Test::More

=head1 SEE ALSO

perl(1).
Posy

=head1 BUGS

Please report any bugs or feature requests to the author.

=head1 AUTHOR

    Kathryn Andersen (RUBYKAT)
    perlkat AT katspace dot com
    http://www.katspace.com

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2004-2005 by Kathryn Andersen

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Posy::Plugin::RandQuote
__END__
