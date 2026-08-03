module AuthHelpers
  def auth_headers(user)
    token = AuthToken.encode({ user_id: user.id })
    { "Authorization" => "Bearer #{token}" }
  end
end
