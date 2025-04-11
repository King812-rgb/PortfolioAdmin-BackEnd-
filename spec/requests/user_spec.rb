require 'rails_helper'

RSpec.describe UsersController, type: :request do
 let!(:user_for_show) { create(:user) }

  let(:create_valid_attributes) do
    {
      user_id: 'test_user1',
      name: 'Test User',
      email: 'test@example.com'
    }
  end

  let(:create_invalid_attributes) do
    {
      user_id: '',
      name: '',
      email: ''
    }
  end

  let(:headers) { { 'Authorization' => "Bearer #{ENV['API_KEY']}" } }
  let(:invalid_headers) { { 'Authorization' => 'invalid_token' } }

  ## GETのテストケース
  describe 'GET #show' do
    context 'with valid authorization' do
    it 'returns the correct user' do
      get "/user/#{user_for_show.id}", headers: headers
      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body['status']).to eq('success')
      expect(body['user']['id']).to eq(user_for_show.id)
    end
  end

  context 'with invalid authorization' do
    it 'returns an unauthorized response' do
      get "/user/#{user_for_show.id}", headers: invalid_headers
      body = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(body['status']).to eq('error')
      expect(body['error']['code']).to eq('UNAUTHORIZED')
    end
  end

    context 'when user does not exist' do
      it 'returns a not found response' do
        get "/user/999", headers: headers
        body = JSON.parse(response.body)
        expect(response.status).to eq(404)
        expect(body['status']).to eq('error')
        expect(body['error']['code']).to eq('NOT_FOUND')
        expect(body['error']['message']).to eq('User not found')
      end
    end

    context 'when failed to get User' do
      before do
        allow(User).to receive(:find_by).and_raise(ActiveRecord::RecordNotFound.new("Couldn't find User with 'id'=999"))
      end
      it 'returns a not found response' do
        get "/user/#{user_for_show.id}", headers: headers
        body = JSON.parse(response.body)
        expect(response.status).to eq(500)
        expect(body['status']).to eq('error')
        expect(body['error']['code']).to eq('INTERNAL_SERVER_ERROR')
        expect(body['error']['message']).to eq('An unexpected error occurred.')
      end
    end
  end

    ## CREATEのテストケース
    describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Work' do
        expect {
          post '/user/create', params: create_valid_attributes, headers: headers
        }.to change(User, :count).by(1)
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Work and returns an error' do
        post '/user/create', params: create_invalid_attributes, headers: headers
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
        expect(JSON.parse(response.body)['error']['message']).to eq('Missing required parameters: user_id, name, email')
      end
    end

    context 'without parameters' do
      it 'returns an error when parameters are missing' do
        post '/user/create', headers: headers
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
        expect(JSON.parse(response.body)['error']['message']).to eq('Missing required parameters: user_id, name, email')
      end
    end

    context 'with invalid authorization' do
      it 'returns an unauthorized response' do
        post '/user/create', params: create_valid_attributes, headers: invalid_headers

        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('UNAUTHORIZED')
      end
    end

    context 'when failed to create User' do
      before do
        allow(User).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(User.new))
      end
      it 'returns an error when failed to create User' do
        post '/user/create', params: create_valid_attributes, headers: headers
        body = JSON.parse(response.body)
        expect(response.status).to eq(500)
        expect(body['status']).to eq('error')
        expect(body['error']['code']).to eq('INTERNAL_SERVER_ERROR')
        expect(body['error']['message']).to eq('An unexpected error occurred.')
      end
    end
  end
end
