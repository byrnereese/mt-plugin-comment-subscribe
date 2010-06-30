package CommentSubscribe::CommentSubscriptions;

use strict;

use MT::Object;
@CommentSubscribe::CommentSubscriptions::ISA = qw(MT::Object);

__PACKAGE__->install_properties(
    {
        column_defs => {
            'id'       => 'integer not null auto_increment',
            'blog_id'  => 'integer not null',
            'entry_id' => 'integer not null',
            'email'    => 'string(255)',
            'uniqkey'  => 'string(30)',
        },
        indexes => {
            'blog_id'  => 1,
            'entry_id' => 1,
            'email'    => 1,
            'uniqkey'  => 1,
        },
        primary_key => 'id',
        audit       => 1,
        datasource  => 'commentsubscriptions',
    }
);

1;
