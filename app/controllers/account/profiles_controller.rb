# frozen_string_literal: true

module Account
  class ProfilesController < ApplicationController
    # before_action :purge_avatar, only: :update
    def show; end

    def edit; end

    def update
      return redirect_to profile_path, notice: t('.success') if current_user.update_without_password(profile_params)

      render(:edit)
    end

    def save_articles_from_yoksis
      Yoksis::ArticlesSaveJob.perform_later(current_user)
      redirect_to(:profile, notice: t('.will_update'))
    end

    def save_books_from_yoksis
      Yoksis::BooksSaveJob.perform_later(current_user)
      redirect_to(:profile, notice: t('.will_update'))
    end

    def save_projects_from_yoksis
      Yoksis::ProjectsSaveJob.perform_later(current_user)
      redirect_to(:profile, notice: t('.will_update'))
    end

    def save_certifications_from_yoksis
      Yoksis::CertificationsSaveJob.perform_later(current_user)
      redirect_to(:profile, notice: t('.will_update'))
    end

    def save_academic_credentials_from_yoksis
      Yoksis::AcademicCredentialsSaveJob.perform_later(current_user)
      redirect_to(:profile, notice: t('.will_update'))
    end

    def save_education_informations_from_yoksis
      Yoksis::EducationInformationsSaveJob.perform_later(current_user)
      redirect_to(:profile, notice: t('.will_update'))
    end

    private

    # def purge_avatar
    #   current_user.avatar.purge
    # end

    def profile_params
      params.require(:user).permit(
        :avatar, :country, :fixed_phone, :extension_number, :website, :twitter, :linkedin, :skype, :orcid
      )
    end
  end
end
