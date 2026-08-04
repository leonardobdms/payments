require "swagger_helper"

RSpec.describe "Api::V1::Users::Registrations", type: :request do
  describe "Register" do
    path "/api/v1/register" do
      post "Create a new user account" do
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
                name: { type: :string },
                cpf: { type: :string },
                password: { type: :string },
                password_confirmation: { type: :string }
              },
              required: %w[email name cpf password password_confirmation]
            }
          },
          required: %w[user]
        }

        response "201", "Created" do
          let(:password) { "password123" }
          let(:email) { Faker::Internet.email }
          let(:cpf) { Faker::IdNumber.brazilian_cpf }
          let(:body) do
            {
              user: {
                email: email,
                name: "Novo Usuario",
                cpf: cpf,
                password: password,
                password_confirmation: password
              }
            }
          end

          run_test! do |response|
            expect(response).to have_http_status(:created)
            expect(response.parsed_body).to include("access_token", "refresh_token", "user")
            expect(response.parsed_body["user"]).to include(
              "email" => email,
              "name" => "Novo Usuario",
              "cpf" => cpf
            )
            expect(response.parsed_body["user"].keys).not_to include("password_digest")
            expect(AuthToken::Token.decode(response.parsed_body["access_token"])[:user_id]).to eq(
              response.parsed_body["user"]["id"]
            )
            expect(User.find(response.parsed_body["user"]["id"]).refresh_tokens.count).to eq(1)
          end
        end

        response "422", "Unprocessable Content" do
          let(:existing_user) { create(:user) }
          let(:password) { "password123" }
          let(:body) do
            {
              user: {
                email: existing_user.email,
                name: "Outro Nome",
                cpf: existing_user.cpf,
                password: password,
                password_confirmation: password
              }
            }
          end

          run_test! do |response|
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body).to have_key("errors")
          end
        end
      end
    end
  end
end
