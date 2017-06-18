FROM nginx
MAINTAINER jad.gaspar@gmail.com

# html directory with version.txt file
COPY html /usr/share/nginx/html
