Rails.application.routes.draw do
  post 'shorten', to: 'urls#shorten'
  get '/:short_url', to: 'urls#redirect'
end