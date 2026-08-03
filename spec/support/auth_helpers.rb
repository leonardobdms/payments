module AuthHelpers
  def auth_headers(user)
    token = AuthToken::Token.encode({ user_id: user.id })
    { "Authorization" => "Bearer #{token}" }
  end
end
