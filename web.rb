require 'sinatra'
require_relative './deploys'

set :port, ENV['PORT'] || 3000

get '*' do
  Deploys.get(ENV['MAX_DEPLOYS']).join(',')
end
