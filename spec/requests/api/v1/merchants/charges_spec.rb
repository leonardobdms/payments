require "swagger_helper"

RSpec.describe "Api::V1::Merchants::Charges", type: :request do
  let(:user) { create(:user) }
  let!(:merchant) { create(:merchant, user: user) }

  describe "Create charge" do
    path "/api/v1/merchants/{merchant_id}/charges" do
      post "Create charge" do
        tags "Charges"

        security [ BearerAuth: [] ]

        consumes "application/json"
        produces "application/json"

        parameter name: :merchant_id, in: :path, type: :integer, required: true

        parameter name: :body, in: :body, schema: {
          type: :object,
          properties: {
            charge: {
              type: :object,
              properties: {
                amount_cents: { type: :integer, minimum: 1 },
                payment_method: { type: :string, enum: %w[pix card] },
                description: { type: :string },
                customer_email: { type: :string },
                customer_document: { type: :string }
              },
              required: %w[amount_cents payment_method]
            }
          },
          required: %w[charge]
        }

        response "201", "Created pix charge" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:merchant_id) { merchant.id }
          let(:body) do
            {
              charge: {
                amount_cents: 50_00,
                payment_method: "pix",
                description: "Assinatura mensal"
              }
            }
          end

          run_test! do |response|
            expect(response).to have_http_status(:created)
            expect(response.parsed_body).to include(
              "amount_cents" => 50_00,
              "currency" => "BRL",
              "status" => "processing",
              "payment_method" => "pix",
              "provider" => "mock"
            )
            expect(response.parsed_body["public_id"]).to start_with("ch_")
            expect(response.parsed_body["metadata"]).to have_key("mock_pix")
          end
        end

        response "201", "Created card charge" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:merchant_id) { merchant.id }
          let(:body) do
            {
              charge: {
                amount_cents: 30_00,
                payment_method: "card"
              }
            }
          end

          run_test! do |response|
            expect(response).to have_http_status(:created)
            expect(response.parsed_body["status"]).to eq("succeeded")
            expect(merchant.account.reload.available_balance_cents).to eq(30_00)
          end
        end

        response "401", "Unauthorized" do
          let(:Authorization) { "Bearer invalid.token" }
          let(:merchant_id) { merchant.id }
          let(:body) { { charge: { amount_cents: 10_00, payment_method: "pix" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unauthorized)
          end
        end

        response "404", "Merchant not found" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:merchant_id) { 0 }
          let(:body) { { charge: { amount_cents: 10_00, payment_method: "pix" } } }

          run_test! do |response|
            expect(response).to have_http_status(:not_found)
          end
        end

        response "422", "Unprocessable Content" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:merchant_id) { merchant.id }
          let(:body) { { charge: { amount_cents: 0, payment_method: "pix" } } }

          run_test! do |response|
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body).to have_key("errors")
          end
        end
      end
    end
  end

  describe "List charges" do
    path "/api/v1/merchants/{merchant_id}/charges" do
      get "List merchant charges" do
        tags "Charges"

        security [ BearerAuth: [] ]

        produces "application/json"

        parameter name: :merchant_id, in: :path, type: :integer, required: true

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:merchant_id) { merchant.id }
          let!(:charges) { create_list(:charge, 2, merchant: merchant) }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body.size).to eq(2)
            expect(response.parsed_body.map { |c| c["public_id"] })
              .to match_array(charges.map(&:public_id))
          end
        end
      end
    end
  end
end
