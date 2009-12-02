package CommentSubscribe::Plugin;

use strict;

sub process_new_comment {
    my ($cb, $obj, $original) = @_;

    # If the object is visible ("published"), then this is not spam.
    # Check for spam content first! This way, the CommentSubscribe
    # table isn't flooded with spam email addresses.
    
    if ($obj->visible || $obj->junk_status == 1) { # 1 == MT->model('comment')::NOT_JUNK) { 

        my $app = MT->instance(); # Store the instance in a variable, we need it more often

        my $blog_id  = $obj->blog_id;
        my $entry_id = $obj->entry_id;
        my $email    = $obj->email;

        if($app->param('subscribe') && $email){ 
            # don't bother if the user hasn't left an email address or if the comment is not yet visible
            if(!MT->model('commentsubscriptions')->load({ 'blog_id' => $blog_id,
                                                          'entry_id' => $entry_id,
                                                          'email' => $email })){
                my $csub = MT->model('commentsubscriptions')->new;
                $csub->blog_id($blog_id);
                $csub->entry_id($entry_id);
                $csub->email($email);
                $csub->save;
            }
        }

        # Get entry details
        my $entry = MT->model('entry')->load({'blog_id' => $blog_id,
                         'id' => $entry_id});

        my $from_email = $entry->author()->email;
        my $blog = $entry->blog;

        # Send email
        my @addresses = MT->model('commentsubscriptions')->load({
            'blog_id' => $blog_id,
            'entry_id' => $entry_id
        });
    
        # Changed to use translate method for L10N
        my $subject = $plugin->translate("([_1]) New Comment on [_2]", $blog->name, $entry->title);
    
        require MT::Mail;
        foreach my $addy (@addresses){
            my %head = ( To => $addy->email,
                         Subject => $subject,
                         # Added a from of either the system email or commenter email 
                         # (previously it would use root server email)
                         From => $from_email #$app->config('EmailAddressMain') || $addy->email
                );
        
            # Here we build the email from a template rather than raw text. More powerful, easier to edit, L10N 
            my $base = $app->config('CGIPath');
            $base .= '/' unless $base =~ m!/$!;
            my $param = {
                entry_title     => $entry->title,
                # Using entry_permalink so that it generates the "preferred" link
                entry_permalink => $entry->permalink,
                comment_author  => $obj->author,
                comment_text    => $obj->text,
                unsub_link      => $app->uri(
                    'mode' => 'unsub',
                    'id'   => $addy->id,
                )
            };
        
            # load_tmpl loads it from the plugin's tmpl directory
            my $body = $app->build_page( $plugin->load_tmpl('commentsubscribe_notify.tmpl'), $param);

            if($addy->email ne $email){ # Don't sent to the commenter
                MT::Mail->send(\%head, $body);
              }
        }
    }
}

sub unsub {
    my $app = shift;

    my $action = $app->{query}->param('action');
    my $id     = int($app->{query}->param('id'));
    
    if($action eq "unsub" && $id){
        my $obj = MT->model('commentsubscriptions')->load( $id );
        $obj->remove();
        return "You are now unsubscribed from this entry's comments.";
    }
    
    return "I'm afraid I don't understand that.";
}

1;
