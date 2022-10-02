require 'rails_helper'

RSpec.describe "Api::SecretMessages", type: :request do
  let(:karo) { create(:user, name: 'karo', password: 'ps') }

  describe "GET /api/select_messages" do
    let(:karo_message) { create(:secret_message, owner: karo) }

    context '正しいAuthorizationヘッダあり' do
      let(:valid_basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials(karo.name, karo.password) }

      it '成功' do
        get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

        expect(response).to have_http_status(200)
      end
    end

    context '誤ったAuthorizationヘッダ' do
      let(:invalid_basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials('foo', 'bar') }

      it 'エラー' do
        get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: invalid_basic_auth }

        expect(response).to have_http_status(401)
      end
    end

    context 'Authorizationヘッダなし' do
      it 'エラー' do
        get api_secret_messages_path

        expect(response).to have_http_status(401)
      end
    end
  end
end
