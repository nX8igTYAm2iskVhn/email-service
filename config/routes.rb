EmailService::Application.routes.draw do

  scope 'v1' do
    resources :emails, only: [:create]
    post '/emails/:template' => 'emails#create'
  end

end
