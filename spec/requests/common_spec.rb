RSpec.describe "Common", type: :request do
  it "returns 404 with appropriate error message when endpoint does not exist" do
    headers = { 'Authorization' => "Bearer #{ENV['API_KEY']}" }
    get "/not_existing_endpoint", headers: headers

    expect(response.status).to eq(404)
    body = JSON.parse(response.body)
    expect(body['status']).to eq('error')
    expect(body['error']['code']).to eq('NOT_FOUND')
    expect(body['error']['message']).to eq('The requested endpoint does not exist.')
  end
end
