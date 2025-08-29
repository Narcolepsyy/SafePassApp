# frozen_string_literal: true
#
class PasswordStrengthsController < ApplicationController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  def create
    password = params[:password].to_s
    resp = PasswordStrengthClient.check(password)

    render json: {
      ok: resp.ok,
      label: resp.label,
      score: resp.score
    }
  end
end

