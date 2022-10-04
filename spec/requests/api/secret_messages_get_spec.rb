require 'rails_helper'

RSpec.describe "Api::SecretMessages", type: :request do
  let(:samurai) { {} }
  let(:parsed_response_body) { JSON.parse(response.body) }

  describe "GET /api/select_messages" do
    let!(:secret_message) { create(:secret_message, owner: samurai, title: '密書1') }
    let!(:another_message) { create(:secret_message, owner: samurai, title: '密書2') }

    context '正しいAuthorizationヘッダあり' do
      let(:valid_basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials(samurai.name, samurai.password) }

      context '家老ロール' do
        let!(:samurai) { create(:chief_retainer, name: 'samurai', password: 'ps') }

        context 'authorに含まれる' do
          before do
            create(:author, user: samurai, secret_message: secret_message)
            create(:author, user: samurai, secret_message: another_message)
          end
          it '成功' do
            get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

            expect(response).to have_http_status(200)
            expect(parsed_response_body.length).to eq(2)

            titles = parsed_response_body.map {|msg| msg['title']}
            expect(titles).to eq(%w[密書1 密書2])
          end
        end

        context 'authorに含まれない' do
          it '成功' do
            get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

            expect(response).to have_http_status(200)
            expect(parsed_response_body.length).to eq(2)

            titles = parsed_response_body.map {|msg| msg['title']}
            expect(titles).to eq(%w[密書1 密書2])
          end
        end
      end

      context '奉行ロール' do
        let!(:samurai) { create(:magistrate, name: 'samurai', password: 'ps') }

        context 'authorに含まれる' do
          before do
            create(:author, user: samurai, secret_message: secret_message)
          end

          it '成功' do
            get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

            expect(response).to have_http_status(200)

            expect(parsed_response_body.length).to eq(1)

            titles = parsed_response_body.map {|msg| msg['title']}
            expect(titles).to eq(%w[密書1])
          end
        end

        context 'authorに含まれない' do
          it '失敗' do
            get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

            expect(response).to have_http_status(200)
            expect(parsed_response_body.length).to eq(0)
          end
        end
      end

      context 'ロールなし' do
        let!(:samurai) { create(:user, name: 'samurai', password: 'ps') }

        it '失敗' do
          get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

          expect(response).to have_http_status(403)
        end
      end
    end

    context '誤ったAuthorizationヘッダ' do
      let!(:samurai) { create(:user, name: 'samurai', password: 'ps') }
      let!(:invalid_basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials('foo', 'bar') }

      it 'エラー' do
        get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: invalid_basic_auth }

        expect(response).to have_http_status(401)
      end
    end

    context 'Authorizationヘッダなし' do
      let!(:samurai) { create(:user, name: 'samurai', password: 'ps') }

      it 'エラー' do
        get api_secret_messages_path

        expect(response).to have_http_status(401)
      end
    end
  end
end
