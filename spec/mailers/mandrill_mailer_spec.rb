require 'spec_helper'

describe MandrillMailer do

  describe '#email' do
    let(:mail) { MandrillMailer.email(options) }
    let(:mail2) { MandrillMailer.email(options2) }
    let(:to_override) { ['nX8igTYAm2iskVhn-systems@example.com'] }
    let(:options) {{
      to: ['some_email@email.com'],
      from: ['boberto@gmail.com'],
      subject: 'Closing Trading Day',
      body: html_body
    }}
    let(:options2) do
      options[:body] = html_body2
      options
    end

    let(:html_body) { "<!DOCTYPE html><html><head></head><body> Email text \n </body></html>" }
    let(:html_body2) { "<!DOCTYPE html><html><head></head><body></body></html>" }

    context 'given a to email, from email, subject and body' do
      let(:expected_subject) { '[email-service TEST] Closing Trading Day' }

      context 'and prod' do
        before { Rails.stub(env: ActiveSupport::StringInquirer.new("production")) }

        it 'calls mail with the original to option' do
          expect(mail.to).to eq options[:to]
        end
      end

      context 'and enforce_sending_to_provided_recipients' do
        before { options.merge!({ 'enforce_sending_to_provided_recipients' => true }) }

        it 'calls mail with the original to option' do
          expect(mail.to).to eq options[:to]
        end
      end

      context 'and neither prod nor enforce_sending_to_provided_recipients' do
        it 'overrides the to field' do
          expect(mail.to).to eq to_override
        end
      end

      it 'calls mail with the from option' do
        expect(mail.from).to eq options[:from]
      end

      it 'calls mail with the expected subject option' do
        expect(mail.subject).to eq expected_subject
      end

      it 'calls mail with the body option with line breaks' do
        expect(mail.html_part.body).to eq options[:body]
      end

      it 'calls mail with the body option without line breaks' do
        expect(mail2.html_part.body).to eq options2[:body]
      end

      it 'calls mail with the default bcc' do
        expect(mail.bcc).to eq ['bc-email-dump@example.com','mosta@example.com']
      end
    end

    context 'given a bcc' do
      let(:bcc) { 'foo@bar.com' }
      before  { options.merge!(bcc: bcc) }

      context ' and prod' do
        before { Rails.stub(env: ActiveSupport::StringInquirer.new("production")) }

        it 'calls mail with the default bcc and the specified bcc' do
          expect(Rails.env.production?).to be_true
          expect(mail.bcc).to eq ['bc-email-dump@example.com','mosta@example.com', bcc]
        end
      end

      context ' and non-prod' do
        it 'calls mail with the default bcc' do
          expect(Rails.env.production?).to be_false
          expect(mail.bcc).to eq ['bc-email-dump@example.com','mosta@example.com']
        end
      end

      context ' and prod and override_default_bcc' do
        let(:bcc) { 'foo@bar.com' }
        before  { options.merge!(override_default_bcc: true) }
        before { Rails.stub(env: ActiveSupport::StringInquirer.new("production")) }

        it 'calls mail with the default bcc and the specified bcc' do
          expect(Rails.env.production?).to be_true
          expect(mail.bcc).to eq [bcc]
        end
      end
    end

    context 'given a x_mc_tags option' do
      let(:tags) { ['tags-are-great','i-concur'] }
      before  { options.merge!(x_mc_tags: tags) }

      it 'adds the tags to the header under X-MC-Tags' do
        expect(mail.header['X-MC-Tags'].value).to eq tags.join(",")
      end
    end

    context 'given an attachments option' do
      let(:options) {{
        to: ['some_email@email.com'],
        from: ['boberto@gmail.com'],
        subject: 'Closing Trading Day',
        body: html_body,
        attachments: attachments
      }}
      context 'with invalid attachment' do
        let(:attachments) {
           ["Invalid text attachment"]
        }
        it 'should raise an exception' do
          expect{mail}.to raise_error(ArgumentError)
        end
      end
      context 'with one single attachment' do
        let(:attachments) {
           [{name: "text_file.txt", content: "Sample text attachment"}]
        }
        it 'adds the attachment with relevant content type' do
          expect(mail.attachments).to have(1).attachment
          attachment = mail.attachments[0]
          expect(attachment).to be_a_kind_of(Mail::Part)
          expect(attachment.content_type).to be_start_with('text/plain')
          expect(attachment.filename).to eq 'text_file.txt'
        end
        context 'with custom content type' do
          let(:attachments) {
            [{name: "text_file.txt", content: "Sample text attachment", mime_type: "text/html"}]
          }
          it 'adds the attachment with custom content type' do
            expect(mail.attachments[0].content_type).to be_start_with('text/html')
          end
        end

      end

      context 'with multiple attachments' do
        let(:attachments) {
          [
            {name: "text_file.txt", content: "Sample text attachment"},
            {name: "image.gif", content: "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"},
          ]
        }
        it 'adds the attachment with relevant content type' do
          expect(mail.attachments).to have(2).attachment
          mail.attachments.each_with_index do |attachment, idx|
            expect(attachment).to be_a_kind_of(Mail::Part)
            expect(attachment.filename).to eq attachments[idx][:name]
          end
        end
      end
    end

    context 'given a missing from option' do
      before { options[:from] = nil }

      it 'uses the default from' do
        expect(mail.from).to eq ['support@example.com']
      end
    end

    context 'given a missing to option' do
      before { options[:to] = nil }

      it 'raises an Argument Error' do
        expect{ mail }.to raise_error(':to is missing')
      end
    end

    context 'given a missing subject' do
      before { options[:subject] = nil }

      it 'raises an Argument Error' do
        expect{ mail }.to raise_error(':subject is missing')
      end
    end

    context 'given a missing body' do
      before { options[:body] = nil }

      it 'raises an Argument Error' do
        expect{ mail }.to raise_error(':body is missing')
      end
    end
  end
end
