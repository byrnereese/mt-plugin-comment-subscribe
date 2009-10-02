Comment Subscribe is a plugin for Movable Type which provides similar functionality to the 'Notify me of follow up comments via e-mail' feature on Wordpress. If a user checks a box when posting a comment, they will receive emails every time someone else posts a comment on the same entry. Each email will include a link which the user can use to unsubscribe.

# Installation

To install this plugin follow the instructions found here:

http://tinyurl.com/easy-plugin-install

**Manual Installation**

Unzip the file, and place the CommentSubscribe directory in your plugins directory. If possible, change the permissions on CommentSubscribe/commentsubscribe.cgi to execute for all users, read and write for owner (755). If you don't do this, the plugin will still work, but users will not be able to unsubscribe. Go to your control panel; it will prompt you to upgrade your database. Let it do this; it's just creating a table to accomodate subscriptions.

## Setup 

Add the following to your Comment Form template (in the 'Template Modules' section):

    <div id="comment-form-subscribe">
    <label for="comment-subscribe"><input type="checkbox" id="comment-subscribe" name="subscribe" checked />
    Receive email notification of further comments.</label>
    </div>

You can put it where you like; I put it just above the text area where the user enters their comments.

# How it Works 

If a user subscribes to comments on a given entry, they will be notified every time there's a new comment for that entry. At any time, they'll be able to click on a link in the email they're sent to cancel their subscription. A user won't get notified when they themselves make a comment. Obviously, only users who supply an email address (whether commenting anonymously or through one of the login systems which provides an email address) will get notifications.
