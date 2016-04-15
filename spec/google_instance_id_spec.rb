require 'spec_helper'

describe GoogleInstanceId do
  let(:api_key) { 'API_KEY' }
  let(:instance_id) { described_class.new(api_key) }

  it 'has a version number' do
    expect(GoogleInstanceId::VERSION).not_to be nil
  end

  it 'should raise an error if the api key is not provided' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  describe 'topic management' do
    let(:request_body) { { registration_tokens: registration_tokens, to: "/topics/#{topic }" } }
    let(:registration_tokens) { ['42', '11', '10'] }
    let(:topic) { 'global' }
    let(:request_headers) do
      {
        'Content-Type' => 'application/json',
        'Authorization' => "key=#{api_key}"
      }
    end

    # Reference https://developers.google.com/instance-id/reference/server#create_a_relation_mapping_for_an_app_instance
    let(:success_response) do
      {
        results: [
          { },
          { },
          { } ]
      }
    end

    # Reference https://developers.google.com/instance-id/reference/server#create_a_relation_mapping_for_an_app_instance
    let(:partial_success_response) do
      {
        results: [
          { },
          { error: 'NOT_FOUND' },
          { } ]
      }
    end

    before do
      stub_request(:post, url).with(
        body: request_body.to_json,
        headers: request_headers
      ).to_return(response)
    end

    describe 'add topic' do
      let(:url) { "#{described_class.base_uri}/v1:batchAdd" }
      subject { instance_id.add_topic(registration_tokens, topic) }

      context 'server error' do
        let(:response) { { body: '{}', headers: {}, status: 500 } }

        it 'returns the response' do
          expect(subject.status_code).to eq(500)
        end
      end

      context 'partial success' do
        let(:response) { { body: partial_success_response.to_json, headers: {}, status: 200 } }

        it 'returns the response and add errors' do
          expect(subject.status_code).to eq(200)
          expect(subject.errors.size).to eq(1)
          expect(subject.errors.first.registration_token).to eq('11')
        end
      end

      context 'success' do
        let(:response) { { body: success_response.to_json, headers: {}, status: 200 } }

        it 'returns the response' do
          expect(subject.status_code).to eq(200)
          expect(subject.errors.size).to eq(0)
        end
      end
    end

    describe 'remove topic' do
      let(:url) { "#{described_class.base_uri}/v1:batchRemove" }
      subject { instance_id.remove_topic(registration_tokens, topic) }

      context 'server error' do
        let(:response) { { body: '{}', headers: {}, status: 500 } }

        it 'returns the response' do
          expect(subject.status_code).to eq(500)
        end
      end

      context 'partial success' do
        let(:response) { { body: partial_success_response.to_json, headers: {}, status: 200 } }

        it 'returns the response and add errors' do
          expect(subject.status_code).to eq(200)
          expect(subject.errors.size).to eq(1)
          expect(subject.errors.first.registration_token).to eq('11')
        end
      end

      context 'success' do
        let(:response) { { body: success_response.to_json, headers: {}, status: 200 } }

        it 'returns the response' do
          expect(subject.status_code).to eq(200)
          expect(subject.errors.size).to eq(0)
        end
      end
    end
  end

  describe 'info' do
    let(:url) { "#{described_class.base_uri}/info/#{registration_token}?details=true" }
    let(:registration_token) { 'TOKEN' }
    let(:request_headers) do
      {
        'Content-Type' => 'application/json',
        'Authorization' => "key=#{api_key}"
      }
    end

    subject { instance_id.info(registration_token) }

    before do
      stub_request(:get, url).with(
        headers: request_headers
      ).to_return(response)
    end

    context 'error' do
      let(:response) { { body: '{}', headers: {}, status: 500 } }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'success' do
      let(:response) { { body: body.to_json, headers: {}, status: 200 } }
      let(:body) do
        {
          'application' => 'com.iid.example',
            'authorizedEntity' => '123456782354',
            'platform' => 'Android',
            'attestStatus' => 'ROOTED',
            'appSigner' => '1a2bc3d4e5',
            'connectionType' => 'WIFI',
            'connectDate' => '2015-05-12',
            'rel' => {
              'topics' => {
                'topicname1' => {'addDate' => '2015-07-30'},
                'topicname2' => {'addDate' => '2015-07-30'},
                'topicname3' => {'addDate' => '2015-07-30'},
                'topicname4' => {'addDate' => '2015-07-30'}
              }
            }
        }
      end

      it 'returns registration token info' do
        expect(subject.application).to eq('com.iid.example')
        expect(subject.rel.topics.size).to eq(4)
      end
    end
  end
end
