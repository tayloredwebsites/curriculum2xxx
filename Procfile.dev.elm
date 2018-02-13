# to run this development version of Procfile:
# foreman start -f Procfile.dev

web: ./bin/rails server
webpack: ./bin/webpack-dev-server
