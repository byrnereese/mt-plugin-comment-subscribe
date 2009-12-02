package CommentSubscribe::Plugin;

use strict;

sub process_new_comment {
    my ($cb, $obj, $original) = @_;

    if($obj->visible) { # If the object is visible ("published"), then this is not spam.
                        # Check for spam content first! This way, the CommentSubscribe
                        # table isn't flooded with spam email addresses.

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
            my $base = $app->config('CGIPath');
            $base .= '/' unless $base =~ m!/$!;
            my $param = {
                entry_title => $entry->title,
                # Using entry_permalink so that it generates the "preferred" link
                entry_permalink => $entry->permalink,
                comment_author => $obj->author,
                comment_text => $obj->text,
                # Fixed this to use CGIPath (as defined in mt-config.cgi) because in many cases blog_url != cgipath
                unsub_link => $base . 'plugins/CommentSubscribe/commentsubscribe.cgi?action=unsub&id='.$addy->id
            };
        
            # load_tmpl loads it from the plugin's tmpl directory
            my $body = $app->build_page($plugin->load_tmpl('commentsubscribe_notify.tmpl'), $param);            
        
            if($addy->email ne $email){ # Don't sent to the commenter
                MT::Mail->send(\%head, $body);
              }
        }
    }
}

1;
