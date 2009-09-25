package MT::Plugin::TestPlugin;

use strict;
use base qw( MT::Plugin );

use MT;


my $plugin = MT::Plugin::TestPlugin->new({
    id          => 'CommentSubscribe',
    key         => 'comment-subscribe',
    name        => 'Comment Subscribe',
    description => "Allows viewers to subscribe to recieve emails every time a comment is posted for a given entry.",
    version     => '1.0.2',
    schema_version => '0.1',
    author_name => "Robert Synnott",
    doc_link => "http://myblog.rsynnott.com/software/commentsubscribe.html",
    author_link => "http://myblog.rsynnott.com/",
    plugin_link => "http://myblog.rsynnott.com/software/commentsubscribe.html",
});

MT->add_plugin($plugin);

sub init_registry {
    my $plugin = shift;

    $plugin->registry({
	'object_types' => {
	    'commentsubscriptions' => 'CommentSubscribe::CommentSubscriptions',
	},
	'callbacks' => {
	    'MT::Comment::post_save' => \&process_new_comment,
	},
    });
}

sub process_new_comment {
    my ($cb, $obj, $original) = @_;

    my $app = MT->instance(); # Store the instance in a variable, we need it more often
    my $blog_id = $obj->blog_id;
    my $entry_id = $obj->entry_id;
    my $email = $obj->email;

    require CommentSubscribe::CommentSubscriptions;
        
    if($app->param('subscribe') && $email){ # don't bother if the user hasn't left an email address or if the comment is not yet visible
		if(!CommentSubscribe::CommentSubscriptions->load({ 'blog_id' => $blog_id,
								   'entry_id' => $entry_id,
								   'email' => $email })){
		    my $csub = CommentSubscribe::CommentSubscriptions->new;
		    $csub->blog_id($blog_id);
		    $csub->entry_id($entry_id);
		    $csub->email($email);
		    $csub->save;
		}
    }


    if($obj->visible){
	#Get entry details
	require MT::Entry;
	my $entry = MT::Entry->load({'blog_id' => $blog_id,
				     'id' => $entry_id});

	my $from_email = $entry->author()->email;

	require MT::Blog;
	my $blog = MT::Blog->load($blog_id);
	

	#Send email
	my @addresses = CommentSubscribe::CommentSubscriptions->load({'blog_id' => $blog_id,
								      'entry_id' => $entry_id});
	
	# Changed to use translate method for L10N
	my $subject = $plugin->translate("([_1]) New Comment on [_2]", $blog->name, $entry->title);
	
	require MT::Mail;
	foreach my $addy (@addresses){
	    my %head = ( To => $addy->email,
			 Subject => $subject,
			 # Added a from of either the system email or commenter email (previously it would use root server email)
			 From => $from_email #$app->config('EmailAddressMain') || $addy->email
			 );
	    
	    # Here we build the email from a template rather than raw text. More powerful, easier to edit, L10N	
	    my $base = $blog->site_url;#$app->config('CGIPath');
	    $base .= '/' unless $base =~ m!/$!;		
	    my $param = {
		entry_title => $entry->title,
		# Using entry_permalink so that it generates the "preferred" link
		entry_permalink => $entry->permalink,
		comment_author => $obj->author,
		comment_text => $obj->text,
		# Fixed this to use CGIPath (as defined in mt-config.cgi) because in many cases blog_url != cgipath
		unsub_link =>  'http://www.majordojo.com/cgi-bin/mt/plugins/CommentSubscribe/commentsubscribe.cgi?action=unsub&id='.$addy->id
		};
	    
	    # load_tmpl loads it from the plugin's tmpl directory
	    my $body = $app->build_page($plugin->load_tmpl('commentsubscribe_notify.tmpl'), $param);			
	    
	    if($addy->email ne $email){ # Don't sent to the commenter
	    	MT::Mail->send(\%head, $body);
	      }
	}
    }
}
