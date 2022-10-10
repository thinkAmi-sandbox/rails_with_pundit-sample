require 'rails_helper'

RSpec.describe "Api::SecretMessages", type: :request do
  let(:samurai) { {} }
  let(:parsed_response_body) { JSON.parse(response.body) }
  let!(:faction) { create(:faction, name: '松') }

  describe "GET /api/select_messages" do
    let!(:samurai_message) { create(:secret_message, owner: samurai, title: 'samurai') }
    let!(:another_message) { create(:secret_message, owner: samurai, title: 'another') }

    shared_examples 'すべて閲覧できる' do
      it do
        get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

        expect(response).to have_http_status(200)
        expect(parsed_response_body.length).to eq(2)

        titles = parsed_response_body.map {|msg| msg['title']}
        expect(titles).to eq([samurai_message.title, another_message.title])
      end
    end

    shared_examples '自分がauthorの密書(samurai_message)のみ閲覧できる' do
      it do
        get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

        expect(response).to have_http_status(200)
        expect(parsed_response_body.length).to eq(1)

        titles = parsed_response_body.map {|msg| msg['title']}
        expect(titles).to eq([samurai_message.title])
      end
    end


    shared_examples 'authorに同じ派閥の家老がいる密書(samurai_message)のみ閲覧できる' do
      it do
        get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

        expect(response).to have_http_status(200)
        expect(parsed_response_body.length).to eq(1)

        titles = parsed_response_body.map {|msg| msg['title']}
        expect(titles).to eq([samurai_message.title])
      end
    end

    shared_examples 'authorに同じ派閥の家老がいる密書(another_message)のみ閲覧できる' do
      it do
        get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

        expect(response).to have_http_status(200)
        expect(parsed_response_body.length).to eq(1)

        titles = parsed_response_body.map {|msg| msg['title']}
        expect(titles).to eq([another_message.title])
      end
    end

    shared_examples '閲覧可能なデータがない' do
      it do
        get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

        expect(response).to have_http_status(200)
        expect(parsed_response_body.length).to eq(0)
      end
    end

    shared_examples '閲覧できない' do
      it do
        get api_secret_messages_path, headers: { HTTP_AUTHORIZATION: valid_basic_auth }

        expect(response).to have_http_status(403)
      end
    end

    context '正しいAuthorizationヘッダあり' do
      let(:valid_basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials(samurai.name, samurai.password) }

      context '家老ロール' do
        let!(:samurai) { create(:chief_retainer, name: 'samurai', password: 'ps') }

        context 'authorに含まれる' do
          before do
            create(:author, user: samurai, secret_message: samurai_message)
            create(:author, user: samurai, secret_message: another_message)
          end

          it_behaves_like 'すべて閲覧できる'
        end

        context 'authorに含まれない' do
          it_behaves_like 'すべて閲覧できる'
        end
      end

      context '奉行ロール' do
        let!(:samurai) { create(:magistrate, name: 'samurai', password: 'ps', faction: faction) }

        context 'authorに含まれる' do
          before do
            create(:author, user: samurai, secret_message: samurai_message)
          end

          context '同じ派閥の家老' do
            let!(:karo) { create(:chief_retainer, name: 'karo', password: 'ps', faction: faction) }

            context '同じauthorにいる' do
              before do
                create(:author, user: karo, secret_message: samurai_message)
              end

              it_behaves_like 'authorに同じ派閥の家老がいる密書(samurai_message)のみ閲覧できる'
            end

            context '別のauthorにいる' do
              before do
                create(:author, user: karo, secret_message: another_message)
              end

              # 自分の密書 + 家老分(別のauthorの密書)
              it_behaves_like 'すべて閲覧できる'
            end

            context 'authorにいない' do
              it_behaves_like '自分がauthorの密書(samurai_message)のみ閲覧できる'
            end
          end

          context '同じ派閥の奉行' do
            let!(:bugyo) { create(:magistrate, name: 'bugyo', password: 'ps', faction: faction) }

            context '同じauthorにいる' do
              before do
                create(:author, user: bugyo, secret_message: samurai_message)
              end

              it_behaves_like '自分がauthorの密書(samurai_message)のみ閲覧できる'
            end

            context '別のauthorにいる' do
              before do
                create(:author, user: bugyo, secret_message: another_message)
              end

              it_behaves_like '自分がauthorの密書(samurai_message)のみ閲覧できる'
            end

            context 'いない' do
              it_behaves_like '自分がauthorの密書(samurai_message)のみ閲覧できる'
            end
          end

          context '同じ派閥の一般' do
            context 'いる' do
              let!(:bob) { create(:user, name: 'bob', password: 'ps', faction: faction) }

              it_behaves_like '自分がauthorの密書(samurai_message)のみ閲覧できる'
            end

            context 'いない' do
              it_behaves_like '自分がauthorの密書(samurai_message)のみ閲覧できる'
            end
          end
        end

        context 'authorに含まれない' do
          context '同じ派閥の家老' do
            let!(:karo) { create(:chief_retainer, name: 'karo', password: 'ps', faction: faction) }

            context 'authorにいる' do
              before do
                create(:author, user: karo, secret_message: samurai_message)
              end

              it_behaves_like 'authorに同じ派閥の家老がいる密書(samurai_message)のみ閲覧できる'
            end

            context 'authorにいない' do
              it_behaves_like '閲覧可能なデータがない'
            end
          end

          context '同じ派閥の奉行' do
            let!(:bugyo) { create(:magistrate, name: 'bugyo', password: 'ps', faction: faction) }

            context 'authorにいる' do
              before do
                create(:author, user: bugyo, secret_message: samurai_message)
              end

              it_behaves_like '閲覧可能なデータがない'
            end

            context 'authorにいない' do
              it_behaves_like '閲覧可能なデータがない'
            end
          end

          context '同じ派閥の一般' do
            context 'いる' do
              let!(:bob) { create(:user, name: 'bob', password: 'ps', faction: faction) }

              it_behaves_like '閲覧可能なデータがない'
            end

            context 'いない' do
              it_behaves_like '閲覧可能なデータがない'
            end
          end
        end
      end

      context 'ロールなし(一般)' do
        context '派閥に所属' do
          let!(:samurai) { create(:user, name: 'samurai', password: 'ps', faction: faction) }

          context '同じ派閥の家老' do
            let!(:karo) { create(:chief_retainer, name: 'karo', password: 'ps', faction: faction) }

            context 'authorに含まれる' do
              before do
                create(:author, user: karo, secret_message: samurai_message)
              end

              it_behaves_like 'authorに同じ派閥の家老がいる密書(samurai_message)のみ閲覧できる'
            end

            context 'authorに含まれない' do
              it_behaves_like '閲覧可能なデータがない'
            end
          end

          context '別の派閥の家老' do
            let!(:another_faction) { create(:faction, name: '竹') }
            let!(:another_karo) { create(:chief_retainer, name: 'another', password: 'ps', faction: another_faction) }

            context 'authorに含まれる' do
              before do
                create(:author, user: another_karo, secret_message: samurai_message)
              end

              it_behaves_like '閲覧可能なデータがない'
            end
          end

          context '同じ派閥の奉行' do
            let!(:bugyo) { create(:magistrate, name: 'karo', password: 'ps', faction: faction) }

            context 'authorに含まれる' do
              before do
                create(:author, user: bugyo, secret_message: samurai_message)
              end

              it_behaves_like '閲覧可能なデータがない'
            end

            context 'authorに含まれない' do
              it_behaves_like '閲覧可能なデータがない'
            end
          end

          context '別の派閥の奉行' do
            let!(:another_faction) { create(:faction, name: '竹') }
            let!(:another_bugyo) { create(:chief_retainer, name: 'another', password: 'ps', faction: another_faction) }

            context 'authorに含まれる' do
              before do
                create(:author, user: another_bugyo, secret_message: samurai_message)
              end

              it_behaves_like '閲覧可能なデータがない'
            end
          end
        end

        context '派閥に所属していない' do
          let!(:samurai) { create(:user, name: 'samurai', password: 'ps') }

          context '別の派閥の家老がauthorにいる' do
            let!(:another_faction) { create(:faction, name: '竹') }
            let!(:another_karo) { create(:chief_retainer, name: 'another', password: 'ps', faction: another_faction) }

            before do
              create(:author, user: another_karo, secret_message: samurai_message)
            end

            it_behaves_like '閲覧できない'
          end

          context '別の派閥の奉行がauthorにいる' do
            let!(:another_faction) { create(:faction, name: '竹') }
            let!(:another_bugyo) { create(:chief_retainer, name: 'another', password: 'ps', faction: another_faction) }

            before do
              create(:author, user: another_bugyo, secret_message: samurai_message)
            end

            it_behaves_like '閲覧できない'
          end

          context '別の派閥の役職者がauthorにいない' do
            it_behaves_like '閲覧できない'
          end
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
