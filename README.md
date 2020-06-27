# Trivial example of Dockerizing a perl script #

This is a staged build for a trivial application.  The application simply
retrieves the page https://perl.org and prints the html.  Because this
example is so simple, the entire script can be reproduced here:

```perl
#!/usr/bin/env perl

use 5.030;
use LWP::UserAgent;

my $ua   = LWP::UserAgent->new();
my $resp = $ua->get('https://perl.org');
my $cont = $resp->decoded_content;

say $cont;
```

This script requires the module `LWP::UserAgent`, and `LWP::Protocol::https'`,
neither of which will compile in the `whosgonna/perl-runtime image.  The idea 
is to use the (larger) `whosgonna/perl-build` image to create a temporary
image in which to compile the libraries.  Because `cpm` and `Carton` are used 
for this the libraries will be populated in `/home/perl/local`.  They can then
be copied from this temporary image into a smaller based off of 
`whosgonna/perl-runtime`.

The Dockerfile:
```dockerfile
FROM whosgonna/perl-build AS build

## Copy cpanfile and cpanfile.snapshot from my computer to the image:
COPY cpanfile* ./

## cpm will actually install the modules, but it doesn't create / update the
## cpanfile.snapshot, so we run carton immediately after cpm.  The working
## directory is /home/perl, so the modules will all be in /home/perl/local.
RUN cpm install \
    && carton install



#### Start work on the actual image to be used, based off of the runtime image.
FROM whosgonna/perl-runtime

## Copy in the actual script.  At this point any additional modules, etc.,
## should also be copied to the new image:
COPY example.pl ./

## Copy the cpanfiles and the /home/perl/local directory from the temporary
## image to the final image:
COPY --from=build /home/perl/cpanfile* /home/perl/
COPY --from=build /home/perl/local/    /home/perl/local

## Run the script as the default action.  Note tht carton exec is used here, 
## this makes perl look in  the ./local directory for libraries. 
cmd [ "carton", "exec", "./example.pl" ]
``` 



