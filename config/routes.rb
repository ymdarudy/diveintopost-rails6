Rails.application.routes.draw do
  root "statics#top"
  get :dashboard, to: "teams#dashboard"

  devise_for :users, controllers: {
                       sessions: "users/sessions",
                       registrations: "users/registrations",
                       passwords: "users/passwords",
                     }
  resource :user

  resources :teams do
    patch "change", on: :member
    resources :assigns, only: %i[create destroy]
    resources :agendas, shallow: true do
      resources :articles do
        resources :comments
      end
    end
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
