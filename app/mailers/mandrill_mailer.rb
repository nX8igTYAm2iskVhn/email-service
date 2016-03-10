include ActionView::Helpers

class MandrillMailer < ActionMailer::Base

  default from: 'support@example.com'

  def email(options={})
    options = options.with_indifferent_access

    [:to, :subject, :body].each do |attribute|
      raise ArgumentError, ":#{attribute} is missing" unless options[attribute].present?
      instance_variable_set("@#{attribute}", options[attribute])
    end

    @from = options.delete(:from)
    @attachments = options.delete(:attachments) || []

    unless Rails.env.production? || options[:enforce_sending_to_provided_recipients]
      @to = 'nX8igTYAm2iskVhn-systems@example.com'
      @subject = "[email-service #{Rails.env.to_s.upcase}] #{@subject}"
    end

    headers 'X-MC-Autotext' => true
    headers 'X-MC-Tags' => options[:x_mc_tags].join(",") unless options[:x_mc_tags].blank?


    @attachments.each do |attachment|
      unless attachment.is_a?(Hash) && (attachment.keys & ["name", "content"]).any?
        raise ArgumentError, "Attachment requires :name and :content values"
      end
      attachments[attachment[:name]] = {
        mime_type: attachment[:mime_type],
        content: attachment[:content]
      }
    end

    delivery_options = {
      to: @to,
      bcc: generate_bcc(options.delete(:bcc), options.delete(:override_default_bcc)),
      from: @from,
      subject: @subject,
    }.delete_blank

    body_with_line_breaks = word_wrap(@body, line_width: 500)

    mail(delivery_options) do |format|
      format.text { render text: body_with_line_breaks }
      format.html { render text: body_with_line_breaks }
    end
  end

  private

  DEFAULT_BCC = ['bc-email-dump@example.com','mosta@example.com']

  def generate_bcc(bcc_param, override_default_bcc = false)
    base_bcc = override_default_bcc ? [] : DEFAULT_BCC

    if Rails.env.production? &&  bcc_param.present?
      base_bcc + Array(bcc_param)
    else
      base_bcc
    end
  end

end
