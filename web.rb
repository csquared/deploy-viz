require 'sinatra'
require_relative './deploys'

set :port, ENV['PORT'] || 3000

get '*' do
  Deploys.flush!(ENV['MAX_DEPLOYS']).join(',')
end
