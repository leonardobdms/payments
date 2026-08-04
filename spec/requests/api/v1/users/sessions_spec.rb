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
            expect(response.parsed_body).to include("access_token", "refresh_token", "user")
            expect(response.parsed_body["user"]).to include(
              "id" => user.id,
              "email" => user.email,
              "name" => user.name,
              "cpf" => user.cpf
            )
            expect(response.parsed_body["user"].keys).not_to include("password_digest")
            expect(AuthToken::Token.decode(response.parsed_body["access_token"])[:user_id]).to eq(user.id)
            expect(user.refresh_tokens.count).to eq(1)
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

  describe "Refresh" do
    path "/api/v1/refresh" do
      post "Refresh access and refresh tokens" do
        tags "Users"

        consumes "application/json"
        produces "application/json"

        parameter name: :body, in: :body, schema: {
          type: :object,
          properties: {
            refresh_token: { type: :string }
          },
          required: %w[refresh_token]
        }

        response "200", "Success" do
          let!(:tokens) { AuthToken::Refresh.new(user: user).issue }
          let(:body) { { refresh_token: tokens[:refresh_token] } }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to include("access_token", "refresh_token")
            expect(response.parsed_body["refresh_token"]).not_to eq(tokens[:refresh_token])
            expect(AuthToken::Token.decode(response.parsed_body["access_token"])[:user_id]).to eq(user.id)
            expect(AuthToken::Refresh.new(token: tokens[:refresh_token]).refresh!).to be_nil
          end
        end

        response "401", "Unauthorized" do
          let(:body) { { refresh_token: "invalid-token" } }

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

        consumes "application/json"
        security [ BearerAuth: [] ]

        parameter name: :body, in: :body, schema: {
          type: :object,
          properties: {
            refresh_token: { type: :string }
          },
          required: %w[refresh_token]
        }

        response "204", "No Content" do
          let!(:tokens) { AuthToken::Refresh.new(user: user).issue }
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:body) { { refresh_token: tokens[:refresh_token] } }

          run_test! do |response|
            expect(response).to have_http_status(:no_content)
            expect(user.refresh_tokens.first).to be_revoked
            expect(AuthToken::Refresh.new(token: tokens[:refresh_token]).refresh!).to be_nil
          end
        end

        response "401", "Unauthorized" do
          context "with invalid access token" do
            let(:Authorization) { "Bearer invalid.token" }
            let(:body) { { refresh_token: "any-token" } }

            run_test! do |response|
              expect(response).to have_http_status(:unauthorized)
              expect(response.parsed_body).to eq("error" => "Unauthorized")
            end
          end

          context "with refresh token from another user" do
            let(:other_user) { create(:user) }
            let!(:other_tokens) { AuthToken::Refresh.new(user: other_user).issue }
            let(:Authorization) { auth_headers(user)["Authorization"] }
            let(:body) { { refresh_token: other_tokens[:refresh_token] } }

            run_test! do |response|
              expect(response).to have_http_status(:unauthorized)
              expect(other_user.refresh_tokens.first).not_to be_revoked
            end
          end
        end
      end
    end
  end
end
