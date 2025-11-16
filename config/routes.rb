# frozen_string_literal: true
Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  devise_for :users

  root 'dashboard#index'

  resources :consumptions, except: [:show]
  resources :energy_types, except: [:show]
end
