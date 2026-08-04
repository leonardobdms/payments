require "swagger_helper"

RSpec.describe "Api::V1::Merchants::Merchant", type: :request do
  let(:user) { create(:user) }

  describe "Create merchant" do
    path "/api/v1/merchant" do
      post "Register merchant and wallet" do
        tags "Merchants"

        security [ BearerAuth: [] ]

        consumes "application/json"
        produces "application/json"

        parameter name: :body, in: :body, schema: {
          type: :object,
          properties: {
            merchant: {
              type: :object,
              properties: {
                legal_name: { type: :string },
                document: { type: :string }
              },
              required: %w[legal_name document]
            }
          },
          required: %w[merchant]
        }

        response "201", "Created" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:merchant_document) { user.cpf.gsub(/\D/, "") }
          let(:body) do
            {
              merchant: {
                legal_name: "Loja Exemplo LTDA",
                document: merchant_document
              }
            }
          end

          run_test! do |response|
            expect(response).to have_http_status(:created)
            expect(response.parsed_body).to include(
              "legal_name" => "Loja Exemplo LTDA",
              "status" => "active"
            )
            expect(response.parsed_body["account"]).to include(
              "currency" => "BRL",
              "available_balance_cents" => 0,
              "pending_balance_cents" => 0
            )
            expect(user.reload.merchant).to be_present
          end
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid.token" }
          let(:body) { { merchant: { legal_name: "X", document: create(:user).cpf } } }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
          end
        end

        response "409", "Conflict" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:merchant) { create(:merchant, user: user) }
          let(:body) { { merchant: { legal_name: "Outro", document: create(:user).cpf } } }

          run_test! do |response|
            expect(response).to have_http_status(:conflict)
            expect(response.parsed_body).to eq("error" => "Merchant already exists")
          end
        end

        response "422", "Unprocessable Content" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:body) { { merchant: { legal_name: "", document: "invalid" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body).to have_key("errors")
          end
        end
      end
    end
  end

  describe "Show merchant" do
    path "/api/v1/merchant" do
      get "Get my merchant and wallet" do
        tags "Merchants"

        security [ BearerAuth: [] ]

        produces "application/json"

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:merchant) { create(:merchant, :with_balances, user: user) }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to include(
              "id" => merchant.id,
              "legal_name" => merchant.legal_name,
              "document" => merchant.document,
              "status" => "active"
            )
            expect(response.parsed_body["account"]).to include(
              "currency" => "BRL",
              "available_balance_cents" => 10_00,
              "pending_balance_cents" => 5_00
            )
          end
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid.token" }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
          end
        end

        response "404", "Not Found" do
          let(:Authorization) { auth_headers(user)["Authorization"] }

          run_test! do |response|
            expect(response).to have_http_status(:not_found)
            expect(response.parsed_body).to eq("error" => "Not Found")
          end
        end
      end
    end
  end

  describe "Update merchant" do
    path "/api/v1/merchant" do
      patch "Update my merchant" do
        tags "Merchants"

        security [ BearerAuth: [] ]

        consumes "application/json"
        produces "application/json"

        parameter name: :body, in: :body, schema: {
          type: :object,
          properties: {
            merchant: {
              type: :object,
              properties: {
                legal_name: { type: :string }
              }
            }
          },
          required: %w[merchant]
        }

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:merchant) { create(:merchant, user: user, legal_name: "Antigo") }
          let(:body) { { merchant: { legal_name: "Novo Nome" } } }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body["legal_name"]).to eq("Novo Nome")
            expect(merchant.reload.legal_name).to eq("Novo Nome")
          end
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid.token" }
          let(:body) { { merchant: { legal_name: "X" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
          end
        end

        response "404", "Not Found" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:body) { { merchant: { legal_name: "X" } } }

          run_test! do |response|
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end
  end
end
