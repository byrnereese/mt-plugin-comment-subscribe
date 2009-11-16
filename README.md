# Comment Subscribe, a plugin for Movable Type

Authors: Robert Synnott. [Now being maintained by Byrne Reese and others on GitHub](http://github.com/byrnereese/mt-plugin-comment-subscribe).  
License: [Artistic License 2.0](http://www.opensource.org/licenses/artistic-license-2.0.php)  
Site: <http://plugins.movabletype.org/comment-subscribe/>

## Overview

Allows a commenter to subscribe to future comments on an entry.


## Requirements

* MT 4.x


## Features

* Adds ability for commenters to subscribe to receive notification email for each comment left after the comment when they choose to subscribe.
* Unsubscribe link is provided in each notification email.
* Only users who supply an email address (whether commenting anonymously or through one of the login systems which provides an email address) will get notifications.
* Email is sent to the subscribing commenter, "from address" is the user leaving the new comment.
* A user won't get notified when they themselves make a comment.

## Documentation

### Setup 

Add the following to the comment form (often this is thee "Comment Form" template in the "Template Modules" section):

    <div id="comment-form-subscribe">
        <label for="comment-subscribe"><input type="checkbox" id="comment-subscribe" name="subscribe" checked />
        Receive email notification of further comments.</label>
    </div>

*This code is typically inserted before or after the comment textarea.*

## Installation

1. Move the Comment Subscribe plugin directory to the MT `plugins` directory.

    Should look like this when installed:

        $MT_HOME/
            plugins/
                CommentSubscribe/
                    (plugin files here)

2. If possible, change the permissions on `$MT_HOME/plugins/CommentSubscribe/commentsubscribe.cgi` to 755 (executable for all users and additionaly read and write for owner). If you don't do this, the plugin will still work, but users will not be able to unsubscribe.
3. Login to MT and continue when prompted to upgrade your database which will create a table to accomodate subscriptions.

[More in-depth plugin installation instructions](http://tinyurl.com/easy-plugin-install).


## Desired Features Wish List

* add ability for email "from address" to optionally be the system email address rather than the email address of the commenter leaving a new comment.


## Support

This plugin is not an official release, and as such support for this plugin is not available.
