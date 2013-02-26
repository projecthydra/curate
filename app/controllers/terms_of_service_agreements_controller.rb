class TermsOfServiceAgreementsController < ApplicationController
  before_filter :authenticate_user!
  respond_to(:html)
  layout 'curate_nd'
  def new
  end

  def create
    if user_just_agreed_to_tos?
      current_user.agree_to_terms_of_service!
      redirect_to classify_path
    else
      flash.now[:notice] = "To proceed, you must agree to the Terms of Service."
      render action: 'new'
    end
  end
  def user_just_agreed_to_tos?
    params[:commit] == i_agree_text
  end
  protected :user_just_agreed_to_tos?

  I_AGREE_TEXT = "I Agree"
  I_DO_NOT_AGREE_TEXT = "I Do Not Agree"
  def i_agree_text
    I_AGREE_TEXT
  end
  helper_method :i_agree_text

  def i_do_not_agree_text
    I_DO_NOT_AGREE_TEXT
  end
  helper_method :i_do_not_agree_text
end