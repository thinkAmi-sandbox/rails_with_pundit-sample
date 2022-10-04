require 'rails_helper'

RSpec.describe "Api::SecretMessages", type: :request do
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
      # let(:samurai) { create(:user, name: 'samurai', password: 'ps') }
      let(:valid_basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials(samurai.name, samurai.password) }

      context '家老ロール' do
        let!(:samurai) { create(:chief_retainer, name: 'samurai', password: 'ps') }

        context 'ownerである密書' do
          let!(:secret_message) { create(:secret_message, owner: samurai) }

          context 'authorに含まれる' do
            it '成功してDBが更新されている' do
              create(:author, user: samurai, secret_message: secret_message)

              put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

              expect(response).to have_http_status(204)

              # reloadで再読み込み
              expect(secret_message.reload).to have_attributes(
                                                 title: '更新タイトル',
                                                 description: '更新説明',
                                                 owner: samurai
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
          let!(:others) { create(:chief_retainer, name: 'others', password: 'ps') }
          let!(:secret_message) { create(:secret_message, owner: others) }

          context 'authorに含まれる' do
            it '成功してDBが更新されている' do
              create(:author, user: samurai, secret_message: secret_message)

              put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

              expect(response).to have_http_status(204)

              # reloadで再読み込み
              expect(secret_message.reload).to have_attributes(
                                                 title: '更新タイトル',
                                                 description: '更新説明',
                                                 owner: others
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

        context '奉行ロール' do
          let(:samurai) { create(:magistrate, name: 'samurai', password: 'ps') }

          context 'ownerである密書' do
            let(:secret_message) { create(:secret_message, owner: samurai) }

            context 'authorに含まれる' do
              it '成功してDBが更新されている' do
                create(:author, user: samurai, secret_message: secret_message)

                put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

                expect(response).to have_http_status(204)

                # reloadで再読み込み
                expect(secret_message.reload).to have_attributes(
                                                   title: '更新タイトル',
                                                   description: '更新説明',
                                                   owner: samurai
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
              it '成功してDBが更新されている' do
                create(:author, user: samurai, secret_message: secret_message)

                put api_secret_message_path(secret_message), params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)

                expect(response).to have_http_status(204)

                # reloadで再読み込み
                expect(secret_message.reload).to have_attributes(
                                                   title: '更新タイトル',
                                                   description: '更新説明',
                                                   owner: others
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
        end

        context '家老ロールなし' do
          let(:samurai) { create(:user, name: 'samurai', password: 'ps') }

          context 'ownerである密書' do
            let(:secret_message) { create(:secret_message, owner: samurai) }

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
