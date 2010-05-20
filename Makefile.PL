use ExtUtils::MakeMaker;

use YAML::Any qw(LoadFile);
my $file = "plugins/CommentSubscribe/config.yaml";
my $version = LoadFile($file)->{version} ||
    die "No version found in $file";

WriteMakefile(
    NAME            => 'Comment Subscribe',
    VERSION         => $version,
    DISTNAME        => 'CommentSubscribe',
);
