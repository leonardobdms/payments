require "swagger_helper"

RSpec.describe "Api::V1::Merchants", type: :request do
  let(:user) { create(:user) }

  describe "Create merchant" do
    path "/api/v1/merchants" do
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
                document: { type: :string, pattern: '^\d{14}$', description: 'CNPJ (14 digits)' }
              },
              required: %w[legal_name document]
            }
          },
          required: %w[merchant]
        }

        response "201", "Created" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:merchant_document) { "54550752000155" }
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
            expect(user.reload.merchants).to be_one
          end
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid.token" }
          let(:body) { { merchant: { legal_name: "X", document: "11222333000181" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
          end
        end

        response "201", "Created again with another document" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:existing) { create(:merchant, user: user) }
          let(:body) do
            {
              merchant: {
                legal_name: "Segunda Loja",
                document: "54550752000155"
              }
            }
          end

          run_test! do |response|
            expect(response).to have_http_status(:created)
            expect(user.reload.merchants.count).to eq(2)
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

  describe "List merchants" do
    path "/api/v1/merchants" do
      get "List my merchants" do
        tags "Merchants"

        security [ BearerAuth: [] ]

        produces "application/json"

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:merchants) { create_list(:merchant, 2, user: user) }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body.size).to eq(2)
            expect(response.parsed_body.map { |m| m["id"] }).to match_array(merchants.map(&:id))
          end
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid.token" }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end

  describe "Show merchant" do
    path "/api/v1/merchants/{id}" do
      get "Get merchant and wallet" do
        tags "Merchants"

        security [ BearerAuth: [] ]

        produces "application/json"

        parameter name: :id, in: :path, type: :integer, required: true

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:merchant) { create(:merchant, :with_balances, user: user) }
          let(:id) { merchant.id }

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
          let!(:merchant) { create(:merchant, user: user) }
          let(:id) { merchant.id }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
          end
        end

        response "404", "Not Found" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:id) { 0 }

          run_test! do |response|
            expect(response).to have_http_status(:not_found)
            expect(response.parsed_body).to eq("error" => "Not Found")
          end
        end
      end
    end
  end

  describe "Update merchant" do
    path "/api/v1/merchants/{id}" do
      patch "Update merchant" do
        tags "Merchants"

        security [ BearerAuth: [] ]

        consumes "application/json"
        produces "application/json"

        parameter name: :id, in: :path, type: :integer, required: true

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
          let(:id) { merchant.id }
          let(:body) { { merchant: { legal_name: "Novo Nome" } } }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body["legal_name"]).to eq("Novo Nome")
            expect(merchant.reload.legal_name).to eq("Novo Nome")
          end
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid.token" }
          let!(:merchant) { create(:merchant, user: user) }
          let(:id) { merchant.id }
          let(:body) { { merchant: { legal_name: "X" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
          end
        end

        response "404", "Not Found" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:id) { 0 }
          let(:body) { { merchant: { legal_name: "X" } } }

          run_test! do |response|
            expect(response).to have_http_status(:not_found)
          end
        end

        response "422", "Unprocessable Content" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:merchant) { create(:merchant, user: user) }
          let(:id) { merchant.id }
          let(:body) { { merchant: { legal_name: "" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body).to have_key("errors")
          end
        end
      end
    end
  end
end
