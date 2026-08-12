require "swagger_helper"

RSpec.describe "Api::V1::Charges", type: :request do
  let(:user) { create(:user) }
  let!(:merchant) { create(:merchant, user: user) }

  describe "Show charge" do
    path "/api/v1/charges/{public_id}" do
      get "Get charge by public id" do
        tags "Charges"

        security [ BearerAuth: [] ]

        produces "application/json"

        parameter name: :public_id, in: :path, type: :string, required: true

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:charge) { create(:charge, :processing, merchant: merchant, amount_cents: 12_00) }
          let(:public_id) { charge.public_id }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to include(
              "public_id" => charge.public_id,
              "amount_cents" => 12_00,
              "status" => "processing"
            )
          end
        end

        response "404", "Not Found" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let(:public_id) { "ch_missing" }

          run_test! do |response|
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end
  end

  describe "Confirm charge" do
    path "/api/v1/charges/{public_id}/confirm" do
      post "Confirm mock pix charge" do
        tags "Charges"

        security [ BearerAuth: [] ]

        produces "application/json"

        parameter name: :public_id, in: :path, type: :string, required: true

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:charge) do
            create(:charge, :processing, merchant: merchant, amount_cents: 40_00, payment_method: "pix")
          end
          let(:public_id) { charge.public_id }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body["status"]).to eq("succeeded")
            expect(merchant.account.reload.available_balance_cents).to eq(40_00)
          end
        end

        response "422", "Not confirmable" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:charge) { create(:charge, :succeeded, merchant: merchant) }
          let(:public_id) { charge.public_id }

          run_test! do |response|
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body).to have_key("error")
          end
        end
      end
    end
  end

  describe "Cancel charge" do
    path "/api/v1/charges/{public_id}/cancel" do
      post "Cancel charge" do
        tags "Charges"

        security [ BearerAuth: [] ]

        produces "application/json"

        parameter name: :public_id, in: :path, type: :string, required: true

        response "200", "Success" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:charge) { create(:charge, :processing, merchant: merchant) }
          let(:public_id) { charge.public_id }

          run_test! do |response|
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body["status"]).to eq("canceled")
          end
        end

        response "422", "Not cancelable" do
          let(:Authorization) { auth_headers(user)["Authorization"] }
          let!(:charge) { create(:charge, :succeeded, merchant: merchant) }
          let(:public_id) { charge.public_id }

          run_test! do |response|
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body).to have_key("error")
          end
        end
      end
    end
  end
end
