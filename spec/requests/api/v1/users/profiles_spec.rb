require "swagger_helper"

RSpec.describe "Api::V1::Users::Profiles", type: :request do
  let(:user) { create(:user) }

  describe "My profile information" do
    path "/api/v1/me" do
      get "Get my profile information" do
        tags "Users"

        security [ BearerAuth: [] ]

        produces "application/json"

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to include(
              "id" => user.id,
              "email" => user.email,
              "name" => user.name,
              "cpf" => user.cpf
            )
            expect(response.parsed_body.keys).not_to include("password_digest")
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

  describe "Update my profile information" do
    path "/api/v1/me" do
      patch "Update my profile information" do
        tags "Users"

        security [ BearerAuth: [] ]

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
              }
            }
          },
          required: %w[user]
        }

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:body) { { user: { name: "Novo Nome" } } }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to include(
              "id" => user.id,
              "name" => "Novo Nome",
              "email" => user.email,
              "cpf" => user.cpf
            )
            expect(response.parsed_body.keys).not_to include("password_digest")
          end
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid.token" }
          let(:body) { { user: { name: "Novo Nome" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
            expect(response.parsed_body).to eq("error" => "Unauthorized")
          end
        end

        response "422", "Unprocessable Content" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:body) { { user: { email: "invalid-email" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body).to have_key("errors")
          end
        end
      end
    end
  end

  describe "Delete my account" do
    path "/api/v1/me" do
      delete "Delete my account" do
        tags "Users"

        security [ BearerAuth: [] ]

        response "204", "No Content" do
          let(:Authorization) { auth_headers(user)["Authorization"] }

          run_test! do |response|
            expect(response).to have_http_status(:no_content)
            expect(User.exists?(user.id)).to be(false)
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
