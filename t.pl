use strict;
use Data::Dumper;

my $base = 'https://uat.signin.mycas.org.uk';
my $url  = $base. '/CASServer/login?service=https%3A%2F%2Fuat.signin.mycas.org.uk%2Fidp%2FAuthn%2FRemoteUser&RelyingPartyId=https://uat.signinportal.mycas.org.uk/shibboleth&LACode=CAS';

use LWP::UserAgent;

my $browser = LWP::UserAgent->new(
	'show_progress' => 1,
	'agent'		=> 'Mozilla/5.0',
);
$browser->cookie_jar({});
push @{ $browser->requests_redirectable }, 'POST';



my ($lt, $action) = &start_login ($browser, $url);

sub start_login {
	my ($ua, $url) = @_;
	my $response = $ua->get ($url);
	die "cant get [$url] ", $response->status_line
		unless $response->is_success;

	my $action;
	if ($response->content =~ m#action="(/CASServer/login.+?)"#) {
		$action = $1;
	}
	my $lt;
	if ($response->content =~ m#name="lt" value="(.+?)"#) {
		$lt= $1;
	}

	return ($lt, $action);
}

my $response = $browser->post ($base . $action,
	[
		'isCASLogin'	=> 'true',
		'lt'		=> $lt,
		'execution'	=> 'e1s1',
		'_eventId'	=> 'submit',
		'browserDetails'=> '',
		'RelyingPartyId'=> 'https://uat.signinportal.mycas.org.uk/shibboleth',
		'LACode'	=> 'CAS',
		#'username'	=> '129371947',
		'username'	=> 'C000500060029',
		'password'	=> 'password',
		'submit'	=> 'Sign-in'
	]
);

die "[$url] error : ", $response->status_line
	unless $response->is_success;

print $response->content;
