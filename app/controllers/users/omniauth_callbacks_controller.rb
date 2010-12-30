class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    # You need to implement the method below in your model
    logger.info(env["omniauth.auth"].inspect)
    @user = User.find_for_twitter_oauth(env["omniauth.auth"], current_user)
    if !@user
      session["username"] = env["omniauth.auth"]['extra']['user_hash']['screen_name']
      redirect_to new_user_registration_url
    elsif @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_data"] = env["omniauth.auth"]
      session["username"] = env["omniauth.auth"]['extra']['user_hash']['screen_name']
      redirect_to new_user_registration_url
    end
  end

end
