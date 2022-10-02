require 'rails_helper'

RSpec.describe "Api::SecretMessages", type: :request do
  let(:karo) { create(:user, name: 'karo', password: 'ps') }
  let(:karo_message) { create(:secret_message, owner: karo) }

  let(:others) { create(:user, name: 'others', password: 'ps') }
  let(:others_message) { create(:secret_message, owner: others) }

  let(:request_body) do
    {
      title: '更新タイトル',
      description: '更新説明',
    }
  end

  let(:header) { {'Content-Type' => 'application/json', 'Accept' => 'application/json'} }
  let(:params) { request_body.to_json }

  describe "PUT /api/select_messages" do
    context '正しいAuthorizationヘッダあり' do
      let(:valid_basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials(karo.name, karo.password) }

      context '家老の密書' do
        subject do
          put api_secret_message_path(karo_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)
        end

        it '成功してDBが更新されている' do
          subject

          expect(response).to have_http_status(204)

          # reloadで再読み込み
          expect(karo_message.reload).to have_attributes(
                                           title: '更新タイトル',
                                           description: '更新説明',
                                           owner: karo
                                         )
        end
      end

      context '他人の密書' do
        subject do
          put api_secret_message_path(others_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)
        end

        it '失敗して、DBは更新されていない' do
          subject

          expect(response).to have_http_status(403)

          # reloadで再読み込み
          expect(others_message.reload).to have_attributes(
                                             title: 'タイトル',
                                             description: '説明'
                                           )
        end
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
