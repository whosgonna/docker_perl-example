FROM whosgonna/perl-build AS build

COPY cpanfile* ./

RUN cpm install \
    && carton install 


FROM whosgonna/perl-runtime

COPY cpanfile* ./
COPY example.pl ./

COPY --from=build /home/perl/local/ local

cmd [ "carton", "exec", "./example.pl" ]
