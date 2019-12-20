describe Fastlane::Actions::ApphosterAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The apphoster plugin is working!")

      Fastlane::Actions::ApphosterAction.run(nil)
    end
  end
end
