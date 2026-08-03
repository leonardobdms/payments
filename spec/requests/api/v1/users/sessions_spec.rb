require "swagger_helper"

RSpec.describe "Api::V1::Users::Sessions", type: :request do
  let(:password) { "password123" }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  describe "Login" do
    path "/api/v1/login" do
      post "Authenticate user and return token" do
        tags "Users"

        consumes "application/json"
        produces "application/json"

        parameter name: :body, in: :body, schema: {
          type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                email: { type: :string },
                password: { type: :string }
              },
              required: %w[email password]
            }
          },
          required: %w[user]
        }

        response "200", "Success" do
          let(:body) { { user: { email: user.email, password: password } } }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to include("token", "user")
            expect(response.parsed_body["user"]).to include(
              "id" => user.id,
              "email" => user.email,
              "name" => user.name,
              "cpf" => user.cpf
            )
            expect(response.parsed_body["user"].keys).not_to include("password_digest")
            expect(AuthToken.decode(response.parsed_body["token"])[:user_id]).to eq(user.id)
          end
        end

        response "401", "Unauthorized" do
          let(:body) { { user: { email: user.email, password: "wrong-password" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
            expect(response.parsed_body).to eq("error" => "Unauthorized")
          end
        end
      end
    end
  end

  describe "Logout" do
    path "/api/v1/logout" do
      delete "Logout current user" do
        tags "Users"

        security [ BearerAuth: [] ]

        response "204", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }

          run_test! do |response|
            expect(response).to have_http_status(:no_content)
          end
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid.token" }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
            expect(response.parsed_body).to eq("error" => "Unauthorized")
          end
        end
      end
    end
  end
end
