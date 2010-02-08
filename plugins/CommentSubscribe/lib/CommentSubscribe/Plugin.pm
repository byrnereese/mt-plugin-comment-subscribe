package CommentSubscribe::Plugin;

use strict;

sub process_new_comment {
    my ( $cb, $obj, $original ) = @_;

    my $plugin = MT->component('CommentSubscribe');

    # If the object is visible ("published"), then this is not spam.
    # Check for spam content first! This way, the CommentSubscribe
    # table isn't flooded with spam email addresses.

    if ( $obj->visible || $obj->junk_status == 1 ) {

        my $app = MT->instance()
          ;    # Store the instance in a variable, we need it more often

        my $blog_id  = $obj->blog_id;
        my $entry_id = $obj->entry_id;
        my $email    = $obj->email;

        if ( $app->param('subscribe') && $email ) {

# don't bother if the user hasn't left an email address or if the comment is not yet visible
            if (
                !MT->model('commentsubscriptions')->load(
                    {
                        'blog_id'  => $blog_id,
                        'entry_id' => $entry_id,
                        'email'    => $email
                    }
                )
              )
            {
                my $csub = MT->model('commentsubscriptions')->new;
                $csub->blog_id($blog_id);
                $csub->entry_id($entry_id);
                $csub->email($email);
                $csub->save;
            }
        }

        # Get entry details
        my $entry = MT->model('entry')->load(
            {
                'blog_id' => $blog_id,
                'id'      => $entry_id
            }
        );

        my $from_email = $entry->author()->email;
        my $blog       = $entry->blog;

        # Send email
        my @addresses = MT->model('commentsubscriptions')->load(
            {
                'blog_id'  => $blog_id,
                'entry_id' => $entry_id
            }
        );

        # Changed to use translate method for L10N
        my $subject =
          $plugin->translate( "([_1]) [_2] posted a new comment on '[_3]'",
            $blog->name, $obj->author, $entry->title );

        require MT::Mail;
        foreach my $addy (@addresses) {
            my %head = (
                To      => $addy->email,
                Subject => $subject,

                # Added a from of either the system email or commenter email
                # (previously it would use root server email)
                From =>
                  $from_email  #$app->config('EmailAddressMain') || $addy->email
            );

            # Here we build the email from a template rather than raw text. 
            # More powerful, easier to edit, L10N
            my $param = {
                entry_title     => $entry->title,
                entry_permalink => $entry->permalink,
                comment_author  => $obj->author,
                comment_text    => $obj->text,
                unsub_link      => $app->base
                  . $app->uri
                  . "?__mode=unsub&id="
                  . $addy->id
            };

            # load_tmpl loads it from the plugin's tmpl directory
            my $body =
              $app->build_page(
                $plugin->load_tmpl('commentsubscribe_notify.tmpl'), $param );

            if ( $addy->email ne $email ) {    # Don't sent to the commenter
                if ( MT->config->DebugMode > 0 ) {
                    MT->log(
                        {
                            blog_id => $blog->id,
                            message => "Sending comment notification to: "
                              . $head{'To'}
                        }
                    );
                }
                MT::Mail->send( \%head, $body );
            } else {
                if ( MT->config->DebugMode > 0 ) {
                    MT->log(
                        {
                            blog_id => $blog->id,
                            message => "NOT sending comment notification to: "
                              . $head{'To'} . " because subscriber is the same as the commenter."
                        }
                    );
                }
            }
        }
    }
}

sub unsub {
    my $app = shift;

    my $id     = int( $app->{query}->param('id') );
    my $plugin = MT->component('CommentSubscribe');

    if ($id) {
        my $obj   = MT->model('commentsubscriptions')->load($id);
        my $entry = MT->model('entry')->load( $obj->entry_id );
        my $blog  = MT->model('blog')->load( $obj->blog_id );
        MT->log(
            {
                blog_id => $blog->id,
                message => "Unsubscribing "
                  . $obj->email
                  . " from "
                  . $entry->title
            }
        );
        $obj->remove();
        return $app->build_page(
            $plugin->load_tmpl('commentsubscribe_unsub.tmpl'),
            {
                entry_title => $entry->title,
                entry_url   => $entry->permalink,
                blog_name   => $blog->name
            }
        );
    }

    return "I'm afraid I don't understand that.";
}

1;
