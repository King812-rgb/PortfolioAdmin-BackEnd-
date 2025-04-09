require 'rails_helper'

RSpec.describe WorksController, type: :request do
 let!(:user_for_show) { create(:user) }
 let!(:user_for_create) { create(:user) }
 let!(:user_for_update) { create(:user) }
 let!(:user_for_delete) { create(:user) }
 let!(:work_for_show) { create(:work, user: user_for_show) }
 let!(:work_for_create) { create(:work, user: user_for_create) }
 let!(:work_for_update) { create(:work, user: user_for_update) }
 let!(:work_for_delete) { create(:work, user: user_for_delete) }

  let(:create_valid_attributes) do
    {
      user_id: user_for_create.id,
      title: 'Test Work',
      description: 'Test Description',
      tech_stack: 'Ruby, Rails',
      screenshot_url: 'https://example.com/screenshot.png',
      site_url: 'https://example.com',
      github_url: 'https://github.com/example',
      released_on: Date.today,
      is_published: true }
  end

  let(:create_invalid_attributes) do
    { user_id: user_for_create.id,
    title: '',
      description: 'Test Description',
      tech_stack: 'Ruby, Rails',
      screenshot_url: 'https://example.com/screenshot.png',
      site_url: 'https://example.com',
      github_url: 'https://github.com/example',
      released_on: Date.today,
      is_published: true
    }
  end

  let(:update_valid_attributes) do
    {
      id: work_for_update.id,
      user_id: user_for_update.id,
      title: 'Updated Title',
      description: 'Updated Description',
      tech_stack: 'Ruby, Rails',
      screenshot_url: 'https://example.com/screenshot.png',
      site_url: 'https://example.com',
      github_url: 'https://github.com/example',
      released_on: Date.today,
      is_published: true
    }
  end

  let(:update_invalid_attributes) do
    {
      id: work_for_update.id,
      user_id: user_for_update.id,
      title: '',
      description: 'Updated Description',
      tech_stack: 'Ruby, Rails',
      screenshot_url: 'https://example.com/screenshot.png',
      site_url: 'https://example.com',
      github_url: 'https://github.com/example',
      released_on: Date.today,
      is_published: true
    }
  end
  let(:update_invalid_attributes_with_invalid_id) do
    update_valid_attributes.merge(id: 999)
  end

  let(:headers) { { 'Authorization' => "Bearer #{ENV['API_KEY']}" } }
  let(:invalid_headers) { { 'Authorization' => 'invalid_token' } }

  ## GETのテストケース
  describe 'GET #show' do
    context 'with valid authorization' do
    it 'returns the correct works' do
      get "/works/#{user_for_show.id}", headers: headers
      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body['status']).to eq('success')
      expect(body['works'].size).to be > 0
      expect(body['works'].any? { |w| w['id'] == work_for_show.id }).to be true
    end
  end

  context 'with invalid authorization' do
    it 'returns an unauthorized response' do
      get "/works/#{user_for_show.id}", headers: invalid_headers
      body = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(body['status']).to eq('error')
      expect(body['error']['code']).to eq('UNAUTHORIZED')
    end
  end

    context 'when work does not exist' do
      it 'returns a not found response' do
        get "/works/999", headers: headers
        body = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(body['status']).to eq('success')
        expect(body['works'].size).to be 0
      end
    end
  end

    ## CREATEのテストケース
    describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Work' do
        expect {
          post '/works/create', params: create_valid_attributes, headers: headers
        }.to change(Work, :count).by(1)
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Work and returns an error' do
        post '/works/create', params: create_invalid_attributes, headers: headers
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
      end
    end

    context 'without parameters' do
      it 'returns an error when parameters are missing' do
        post '/works/create', headers: headers
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
      end
    end

    context 'with invalid authorization' do
      it 'returns an unauthorized response' do
        post '/works/create', params: create_valid_attributes, headers: invalid_headers

        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('UNAUTHORIZED')
      end
    end
  end

  ## UPDATEのテストケース
  describe 'POST #update' do
  context 'with valid parameters' do
    it 'updates the Work' do
      work_before_update = work_for_update.reload
      post "/works/update", params: update_valid_attributes, headers: headers

      work_after_update = Work.find_by(id: update_valid_attributes[:id])
      expect(response.status).to eq(201)
      expect(JSON.parse(response.body)['status']).to eq('success')
      expect(work_after_update.title).to eq('Updated Title')
      expect(work_after_update.updated_at).to be > work_before_update.updated_at
    end
  end

  context 'with invalid parameters' do
    it 'does not update the Work and returns an error' do
      work_before_update = work_for_update.reload
      post "/works/update", params: update_invalid_attributes, headers: headers

      work_after_update = Work.find_by(id: update_invalid_attributes[:id])
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)['status']).to eq('error')
      expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
      expect(work_after_update.title).to eq(work_before_update.title)
      expect(work_after_update.updated_at).to eq(work_before_update.updated_at)
    end
  end

  context 'when user_id is missing' do
    it 'returns a bad request response' do
      post "/works/update", params: update_valid_attributes.except(:user_id), headers: headers
      body = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(body['status']).to eq('error')
      expect(body['error']['code']).to eq('INVALID_PARAM')
      expect(body['error']['message']).to eq('Missing required parameters: user_id')
    end
  end

  context 'when id is missing' do
    it 'returns a bad request response' do
      post "/works/update", params: update_valid_attributes.except(:id), headers: headers
      body = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(body['status']).to eq('error')
      expect(body['error']['code']).to eq('INVALID_PARAM')
      expect(body['error']['message']).to eq('Missing required parameters: id')
    end
  end

  context 'when target Work does not exist' do
    it 'returns a not found response' do
      work_before_update = work_for_update.reload
      post "/works/update", params: update_invalid_attributes_with_invalid_id, headers: headers

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)['status']).to eq('error')
      expect(JSON.parse(response.body)['error']['code']).to eq('NOT_FOUND')
      work_after_update = Work.find_by(id: work_for_update.id)
      expect(work_after_update.title).to eq(work_before_update.title)
      expect(work_after_update.updated_at).to eq(work_before_update.updated_at)
    end
  end

  context 'with invalid authorization' do
    it 'returns an unauthorized response' do
      post "/works/update", params: update_valid_attributes, headers: invalid_headers

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['status']).to eq('error')
      expect(JSON.parse(response.body)['error']['code']).to eq('UNAUTHORIZED')
    end
  end
end

## DELETEのテストケース
describe 'DELETE #destroy' do
    context 'with valid parameters' do
      it 'deletes the Work' do
        work_before_delete = work_for_delete.reload
        expect {
          post "/works/destroy", params: { user_id: user_for_delete.id, id: work_for_delete.id }, headers: headers
        }.to change(Work, :count).by(-1)

        work_after_delete = Work.find_by(id: work_for_delete.id)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('success')
        expect(work_after_delete).to be_nil
      end
    end

    context 'without parameters' do
      it 'returns an error when parameters are missing' do
        post "/works/destroy", headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
        expect(JSON.parse(response.body)['error']['message']).to eq('Missing required parameters: id, user_id')
      end
    end

    context 'without user_id' do
      it 'returns an error when user_id is missing' do
        post "/works/destroy", params: { id: work_for_delete.id }, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
        expect(JSON.parse(response.body)['error']['message']).to eq('Missing required parameters: user_id')
      end
    end

    context 'without id' do
      it 'returns an error when id is missing' do
        post "/works/destroy", params: { user_id: user_for_delete.id }, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('INVALID_PARAM')
        expect(JSON.parse(response.body)['error']['message']).to eq('Missing required parameters: id')
      end
    end

    context 'when Work does not exist(user_id is invalid)' do
      it 'returns a not found response' do
        post "/works/destroy", params: { user_id: 999, id: work_for_delete.id }, headers: headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('NOT_FOUND')
      end
    end

    context 'when Work does not exist(work_id is invalid)' do
      it 'returns a not found response' do
        post "/works/destroy", params: { user_id: user_for_delete.id, id: 999 }, headers: headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('NOT_FOUND')
      end
    end

    context 'with invalid authorization' do
      it 'returns an unauthorized response' do
        post "/works/destroy", params: { user_id: user_for_delete.id, id: work_for_delete.id }, headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['status']).to eq('error')
        expect(JSON.parse(response.body)['error']['code']).to eq('UNAUTHORIZED')
      end
    end
  end
end
