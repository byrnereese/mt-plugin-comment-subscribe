package CSWebServices;

use base 'MT::App';

use CommentSubscribe::CommentSubscriptions;

use strict;

sub init {
    my $app = shift;

    $app->SUPER::init(@_);
    $app->add_methods(
	default => \&process_request,
	);
    #$app->{default_mode} = 'default';
    $app;
}


sub process_request {
    my $app = shift;

    my $action = $app->{query}->param('action');
    my $id = int($app->{query}->param('id'));
    
    if($action eq "unsub" && $id){
	my $obj = CommentSubscribe::CommentSubscriptions->load({ id => $id,
							       });
	$obj->remove();
	return "You are now unsubscribed from this entry's comments.";
    }
    
    return "I'm afraid I don't understand that.";
}
1;
