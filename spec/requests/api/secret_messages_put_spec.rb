require 'rails_helper'

RSpec.describe "Api::SecretMessages", type: :request do
  let(:karo) { create(:user, name: 'karo', password: 'ps') }

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

      context '家老ロールあり' do
        let(:karo) { create(:chief_retainer, name: 'karo', password: 'ps') }

        context 'ownerである密書' do
          let(:secret_message) { create(:secret_message, owner: karo) }

          context 'authorに含まれる' do
            # let(:author) { create(:author, user: karo, secret_message: secret_message) }

            it '成功してDBが更新されている' do
              create(:author, user: karo, secret_message: secret_message)

              put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

              expect(response).to have_http_status(204)

              # reloadで再読み込み
              expect(secret_message.reload).to have_attributes(
                                                 title: '更新タイトル',
                                                 description: '更新説明',
                                                 owner: karo
                                               )
            end
          end

          context 'authorに含まれない' do
            it '失敗して、DBは更新されていない' do
              put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

              expect(response).to have_http_status(403)

              # reloadで再読み込み
              expect(secret_message.reload).to have_attributes(
                                                 title: 'タイトル',
                                                 description: '説明'
                                               )
            end
          end
        end

        context 'ownerではない密書' do
          let(:others) { create(:chief_retainer, name: 'others', password: 'ps') }
          let(:secret_message) { create(:secret_message, owner: others) }

          context 'authorに含まれる' do
            let(:author) { create(:author, user: karo, secret_message: secret_message) }

            it '失敗して、DBは更新されていない' do
              put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

              expect(response).to have_http_status(403)

              # reloadで再読み込み
              expect(secret_message.reload).to have_attributes(
                                                 title: 'タイトル',
                                                 description: '説明'
                                               )
            end
          end

          context 'authorに含まれない' do
            it '失敗して、DBは更新されていない' do
              put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

              expect(response).to have_http_status(403)

              # reloadで再読み込み
              expect(secret_message.reload).to have_attributes(
                                                 title: 'タイトル',
                                                 description: '説明'
                                               )
            end
          end
        end

        context '家老ロールなし' do
          let(:karo) { create(:user, name: 'karo', password: 'ps') }

          context 'ownerである密書' do
            let(:secret_message) { create(:secret_message, owner: karo) }

            it '失敗して、DBは更新されていない' do
              put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

              expect(response).to have_http_status(403)

              # reloadで再読み込み
              expect(secret_message.reload).to have_attributes(
                                                 title: 'タイトル',
                                                 description: '説明'
                                               )
            end
          end

          context 'ownerではない密書' do
            let(:others) { create(:chief_retainer, name: 'others', password: 'ps') }
            let(:secret_message) { create(:secret_message, owner: others) }

            it '失敗して、DBは更新されていない' do
              put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

              expect(response).to have_http_status(403)

              # reloadで再読み込み
              expect(secret_message.reload).to have_attributes(
                                                 title: 'タイトル',
                                                 description: '説明'
                                               )
            end
          end
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
