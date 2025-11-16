# frozen_string_literal: true

shared_examples 'requires authentication' do
  it 'redirects to login page' do
    expect(response).to redirect_to(new_user_session_path)
  end
end
