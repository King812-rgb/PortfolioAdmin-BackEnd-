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

  ## GETのテストケース
  describe 'GET #show' do
    context 'with valid authorization' do
    it 'returns the correct works' do
      headers = { 'Authorization' => ENV['API_KEY'] }
      get "/user/#{user_for_show.id}", headers: headers
      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body['status']).to eq('success')
      expect(body['user'].size).to be > 0
      expect(body['user'].any? { |u| u['id'] == user_for_show.id }).to be true
    end
  end

  context 'with invalid authorization' do
    it 'returns an unauthorized response' do
      headers = { 'Authorization' => 'invalid_token' }
      get "/user/#{user_for_show.id}", headers: headers
      body = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(body['status']).to eq('error')
      expect(body['error']['code']).to eq('UNAUTHORIZED')
    end
  end

    context 'when user does not exist' do
      it 'returns a not found response' do
        headers = { 'Authorization' => ENV['API_KEY'] }
        get "/user/999", headers: headers
        body = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(body['status']).to eq('success')
        expect(body['user'].size).to be 0
      end
    end
  end

    ## CREATEのテストケース
    describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Work' do
        headers = { 'Authorization' => ENV['API_KEY'] }
        expect {
          post '/user/create', params: create_valid_attributes, headers: headers
        }.to change(User, :count).by(1)
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Work and returns an error' do
        headers = { 'Authorization' => ENV['API_KEY'] }
        post '/user/create', params: create_invalid_attributes, headers: headers
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
        expect(JSON.parse(response.body)['error']['message']).to eq('Missing required parameters: user_id, name, email')
      end
    end

    context 'without parameters' do
      it 'returns an error when parameters are missing' do
        headers = { 'Authorization' => ENV['API_KEY'] }
        post '/user/create', headers: headers
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
        expect(JSON.parse(response.body)['error']['message']).to eq('Missing required parameters: user_id, name, email')
    end
  end

    context 'with invalid authorization' do
      it 'returns an unauthorized response' do
        headers = { 'Authorization' => 'invalid_token' }
        post '/user/create', params: create_valid_attributes, headers: headers

        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('UNAUTHORIZED')
      end
    end
  end
end
