FactoryBot.define do
  factory :user do
    sequence(:id) { |n| n.to_s }
    name { 'Test User' }
    sequence(:email) { |n| "test#{n}@example.com" }
  end

  factory :work do
    association :user
    title { 'Test Work' }
    description { 'Test Description' }
    tech_stack { 'Ruby, Rails' }
    screenshot_url { 'https://example.com/screenshot.png' }
    site_url { 'https://example.com' }
    github_url { 'https://github.com/example' }
    released_on { Date.today }
    is_published { true }
  end
end
