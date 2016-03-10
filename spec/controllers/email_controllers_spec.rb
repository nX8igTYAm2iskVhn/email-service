require 'spec_helper'

describe EmailsController do
  describe '#create' do
    subject { post :create, params }

    let(:params) {{
      to: ['nX8igTYAm2iskVhn-systems@example.com'],
      bcc: ['bcc@example.com'],
      override_default_bcc: true,
      from: ['boberto@gmail.com'],
      subject: 'Closing Trading Day'
    }.with_indifferent_access}

    let(:body) { { body: "Dummy body" } }
    let(:mandrill_mailer) { double MandrillMailer }

    context 'when params includes enforce_sending_to_provided_recipients' do
      let(:enforce_recipient) { { 'enforce_sending_to_provided_recipients' => true } }
      let(:merged_params) { params.merge(enforce_recipient).merge(body) }
      before do
         MandrillMailer.stub(:email).and_return(mandrill_mailer)
         mandrill_mailer.stub(:deliver)
         post :create, merged_params
       end

      it 'calls MandrillMailer.email with the modified params hash' do
        expect(MandrillMailer).to have_received(:email).with(merged_params)
      end
    end

    context 'with invalid params' do
      context 'with invalid recipient address' do
        before do
          MandrillMailer.stub(:email).with(anything).and_return(mandrill_mailer)
          mandrill_mailer.stub(:deliver).and_raise(Net::SMTPServerBusy, "401 4.1.3 Bad recipient address syntax")
          params.merge! body
          subject
        end

        it 'returns status 422' do
          expect(response.status).to be 422
        end

        it 'preserves the error message' do
          expect(JSON.parse(response.body)['error']).to include('Bad recipient address syntax')
        end
      end

      context 'with invalid attachments' do
        let(:merged_params) { params.merge(attachments: ["abc"]).merge(body) }
        before do
          post :create, merged_params
        end
        it 'returns status 422' do
          expect(response.status).to be 422
        end

        it 'preserves the error message' do
          expect(JSON.parse(response.body)['error']).to include('Attachment requires :name and :content value')
        end
      end
    end

    context 'with valid params' do
      context 'when params include body' do
        before do
          mandrill_mailer.stub(:deliver)
          params.merge! body
        end

        it "delivers email through mandrill" do
          expect(MandrillMailer).to receive(:email).with(params.merge! body).and_return(mandrill_mailer)
          subject

          expect(mandrill_mailer).to have_received(:deliver)
          expect(response).to be_success
        end

        context 'when attachments param is included' do
          before do
            MandrillMailer.stub(:email).and_return(mandrill_mailer)
            subject
          end

          let(:params) {{
            to: ['nX8igTYAm2iskVhn-systems@example.com'],
            subject: 'Closing Trading Day',
            attachments: [{name: "text_file.txt", content: "Sample text attachment"}]
          }.with_indifferent_access}

          it "delivers email through mandrill" do
            expect(mandrill_mailer).to have_received(:deliver)
            expect(response).to be_success
          end
        end

        context 'when from param is not included' do
          before do
            MandrillMailer.stub(:email).and_return(mandrill_mailer)
            subject
          end

          let(:params) {{
            to: ['nX8igTYAm2iskVhn-systems@example.com'],
            subject: 'Closing Trading Day'
          }.with_indifferent_access}

          it "delivers email through mandrill" do
            expect(mandrill_mailer).to have_received(:deliver)
            expect(response).to be_success
          end
        end
      end

      context 'when params include rocketman_template' do
        let(:rocketman_template) { "some_template" }
        let(:rocketman_data) { {param_1: "some_value"}.with_indifferent_access }

        let(:params) do
          {
            to: 'nX8igTYAm2iskVhn-systems@example.com',
            rocketman_template: rocketman_template,
            rocketman_data: rocketman_data
          }.with_indifferent_access
        end

        before do
          Rocketman.stub(:deliver).and_return(true)
          subject
        end

        it 'delivers email through Rocketman' do
          expect(Rocketman).to have_received(:deliver).with(params[:to], rocketman_template, rocketman_data)
          expect(response).to be_success
        end

        context 'when params are in a different order' do
          let(:params) do
            {
              rocketman_data: rocketman_data,
              rocketman_template: rocketman_template,
              to: 'nX8igTYAm2iskVhn-systems@example.com'
            }.with_indifferent_access
          end

          it 'delivers email through Rocketman' do
            expect(Rocketman).to have_received(:deliver).with(params[:to], rocketman_template, rocketman_data)
            expect(response).to be_success
          end
        end
      end
    end
  end
end
