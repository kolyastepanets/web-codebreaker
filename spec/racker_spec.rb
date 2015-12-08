require './lib/racker'
require 'spec_helper'

describe Racker do

  let(:racker) { Racker.new }

  context "#call" do

    it "calls #new, #response and #finish methods" do
      expect(Racker).to receive_message_chain(:new, :response, :finish)
      Racker.call('env')
    end

  end

  context "#initialize" do
    
  end

end