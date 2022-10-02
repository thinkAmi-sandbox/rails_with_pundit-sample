require 'rails_helper'

RSpec.describe "Api::SecretMessages", type: :request do
  let(:karo) { create(:user, name: 'karo', password: 'ps') }
  let(:request_body) do
    {
      title: '新規タイトル',
      description: '新規説明',
    }
  end

  let(:header) { {'Content-Type' => 'application/json', 'Accept' => 'application/json'} }
  let(:params) { request_body.to_json }

  describe "POST /api/select_messages" do
    context '正しいAuthorizationヘッダあり' do
      let(:valid_basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials(karo.name, karo.password) }

      subject do
        post api_secret_messages_path, params: params, headers: { HTTP_AUTHORIZATION: valid_basic_auth }.merge(header)
      end

      it '成功' do
        subject

        expect(response).to have_http_status(201)
      end

      it 'DBに登録されている' do
        expect { subject }.to change {SecretMessage.first}
                                .from(nil)
                                .to(have_attributes(
                                      title: '新規タイトル',
                                      description: '新規説明',
                                      owner: karo
                                    ))
      end
    end
    
    context '誤ったAuthorizationヘッダ' do
      let(:invalid_basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials('foo', 'bar') }

      subject do
        post api_secret_messages_path, params: params, headers: { HTTP_AUTHORIZATION: invalid_basic_auth }.merge(header)
      end

      it '失敗' do
        subject

        expect(response).to have_http_status(401)
      end

      it 'DBに登録なし' do
        expect { subject }.not_to change(SecretMessage, :count)
      end
    end

    context 'Authorizationヘッダなし' do
      subject do
        post api_secret_messages_path, params: params, headers: header
      end

      it '失敗' do
        subject

        expect(response).to have_http_status(401)
      end

      it 'DBに登録なし' do
        expect { subject }.not_to change(SecretMessage, :count)
      end
    end
  end
end
