Rails.application.routes.draw do
  get "/works/:user_id", to: "works#show"
  post "/works/create", to: "works#create"
  post "/works/update", to: "works#update"
  post "/works/destroy", to: "works#destroy"
  get "/user/:user_id", to: "users#show"
  post "/user/create", to: "users#create"
  match "*unmatched", to: proc { |env|
    [
      404,
      { "Content-Type" => "application/json" },
      [ {
        status: "error",
        error: {
          code: "NOT_FOUND",
          message: "The requested endpoint does not exist."
        }
      }.to_json ]
    ]
  }, via: :all
end
