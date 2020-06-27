FROM whosgonna/perl-build AS build

COPY cpanfile* ./

RUN cpm install \
    && carton install 


FROM whosgonna/perl-runtime

COPY example.pl ./

COPY --from=build /home/perl/cpanfile* /home/perl/
COPY --from=build /home/perl/local/    /home/perl/local

cmd [ "carton", "exec", "./example.pl" ]
