# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      def signup
        result = AuthenticationService.signup(
          user_params: user_signup_params,
          organization_params: organization_signup_params
        )

        if result[:success]
          render json: {
            status: "ok",
            token: result[:token],
            user: serialize_user(result[:user]),
            organization: serialize_organization(result[:organization]),
            role: result[:role]
          }, status: :created
        else
          render json: {
            error: "Signup failed",
            details: result[:errors]
          }, status: 422
        end
      end

      def login
        result = AuthenticationService.login(
          email: params[:email],
          password: params[:password],
          organization_id: params[:organization_id]
        )

        if result[:success]
          render json: {
            status: "ok",
            token: result[:token],
            user: serialize_user(result[:user]),
            organization: serialize_organization(result[:organization]),
            role: result[:role]
          }, status: :ok
        else
          render json: {
            error: result[:error]
          }, status: :unauthorized
        end
      end

      def logout
        render json: {
          status: "ok",
          message: "Logged out successfully"
        }, status: :ok
      end

      private

      def user_signup_params
        params.require(:user).permit(:name, :email, :password)
      end

      def organization_signup_params
        params.require(:organization).permit(:name, :timezone)
      end

      def serialize_user(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          status: user.status
        }
      end

      def serialize_organization(org)
        {
          id: org.id,
          name: org.name,
          slug: org.slug,
          timezone: org.timezone,
          status: org.status
        }
      end
    end
  end
end
