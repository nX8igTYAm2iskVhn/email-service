require 'net/smtp'

class EmailsController < ActionController::Base
  
  rescue_from Net::SMTPServerBusy do |exception|
    if exception.message.include?('401 4.1.3 Bad recipient address syntax')
      render json: { error: exception.message }, status: 422
    else
      render json: { error: exception.message }, status: 500
    end
  end

  rescue_from ArgumentError do |exception|
    render json: { error: exception.message }, status: 422
  end

  def create
    if params_included_for? base_params_for_mandrill_mailer
      MandrillMailer.email(params.slice(*all_params_for_mandrill_mailer)).deliver
    elsif params_included_for? params_for_rocketman
      Rocketman.deliver(params[:to],
                              params[:rocketman_template],
                              params[:rocketman_data])
    else
      return render json: { error: 'Cannot determine delivery method out of params' }, status: 400
    end

    render json: {status: 'sent'}
  end

  private

  def params_included_for?(target_params)
    target_params.each {|key| return false unless params.has_key? key }
    true
  end

  def base_params_for_mandrill_mailer
    ["to", "subject", "body"]
  end

  def all_params_for_mandrill_mailer
    base_params_for_mandrill_mailer.concat([
      "from", "bcc", "override_default_bcc", "x_mc_tags", "enforce_sending_to_provided_recipients", "attachments"
    ])
  end

  def params_for_rocketman
    ["to", "rocketman_template", "rocketman_data"]
  end

end
