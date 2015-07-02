=head1 sbbs-lib.pl

Functions for the Foobar Web Server. This is an example Webmin module for a
simple fictional webserver.

=cut

use WebminCore;
init_config();

=head2 list_sbbs_websites()

Returns a list of all websites served by the Foobar webserver, as hash
references with C<domain> and C<directory> keys.

=cut
sub list_sbbs_websites
{
my @rv;
my $lnum = 0;
open(CONF, $config{'sbbs_conf'});
while(<CONF>) {
	#s/\r|\n//g;
	#s/#.*$//;
	my ($dom, $dir) = split('=', $_);
	
	if ($dir && $dom) {
		push(@rv, { 'domain' => $dom,
			    'directory' => $dir,
			    'line' => $lnum });
		}
	$lnum++;
	}
close(CONF);
return @rv;
}

=head2 create_sbbs_website(&site)

Adds a new website, specified by the C<site> hash reference parameter, which
must contain C<domain> and C<directory> keys.

=cut
sub create_sbbs_website
{
my ($site) = @_;
open_tempfile(CONF, ">>$config{'sbbs_conf'}");
print_tempfile(CONF, $site->{'domain'}." ".$site->{'directory'}."\n");
close_tempfile(CONF);
}

=head2 modify_sbbs_website(&site)

Updates a website specified by the C<site> hash reference parameter, which
must be a modified entry returned from the C<list_sbbs_websites> function.

=cut
sub modify_sbbs_website
{
my ($site) = @_;
my $lref = read_file_lines($config{'sbbs_conf'});
$lref->[$site->{'line'}] = $site->{'domain'}." ".$site->{'directory'};
flush_file_lines($config{'sbbs_conf'});
}

=head2 delete_sbbs_website(&site)

Deletes a website, specified by the C<site> hash reference parameter, which
must have been one of the elements returned by C<list_sbbs_websites>

=cut
sub delete_sbbs_website
{
my ($site) = @_;
my $lref = read_file_lines($config{'sbbs_conf'});
splice(@$lref, $site->{'line'}, 1);
flush_file_lines($config{'sbbs_conf'});
}

=head2 apply_configuration()

Signal the Foobar webserver process to re-read it's configuration files.

=cut
sub apply_configuration
{
kill_byname_logged('HUP', 'sbbsd');
}

1;

