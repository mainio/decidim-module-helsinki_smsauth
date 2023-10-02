# frozen_string_literal: true

shared_context "with telia gateway" do
  let(:dummy_class) do
    Class.new do
      attr_reader :code

      def initialize(phone_number, code, organization: nil, queued: false)
        @phone_number = "tel:#{phone_number}"
        @code = code
        @organization ||= organization
        @queued = queued
      end
    end
  end

  let(:dummy_gateway) { double("DummyClass", constantize: dummy_class) }
  before do
    allow(Decidim::HelsinkiSmsauth).to receive(:country_code).and_return({ country: "FI", code: "+358" })
    allow(Decidim.config).to receive(:sms_gateway_service).and_return(dummy_gateway)
    allow(dummy_gateway).to receive(:contantize).and_return(dummy_class)
    allow(SecureRandom).to receive(:random_number).and_return(1_234_567)
    allow_any_instance_of(dummy_class).to receive(:deliver_code).and_return(true) # rubocop:disable RSpec/AnyInstance
  end
end

shared_context "with single access code" do
  let(:organization) { create(:organization) }
  let!(:auth_metadata) { { school: "0004", grade: 1, phone_number: "+3584551122334" } }
  let!(:creator) { create(:user, :confirmed, :admin, organization: organization) }

  let!(:signin_code_set) { create(:signin_code_set, creator: creator) }
end
