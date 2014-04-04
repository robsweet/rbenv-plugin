require "spec_helper"
require 'rbenv_wrapper'

describe RbenvWrapper do
  context '#setup' do
    let( :launcher ) { stub }
    let( :listener ) { stub }

    context 'for a matrix build using RBENV_VERSION as an axis' do
      before do
        native_build = double Java::HudsonMatrix::MatrixRun
        expects(native_build).to receive(:getBuildVariables) { { 'RBENV_VERSION' => 'ruby-5.4.3'} }

        build = double
        build.expects(:native) { native_build }

        @wrapper = RbenvWrapper.new build, launcher, listener
        @wrapper.setup
      end

      it "should set @version to the matrix build's value" do
        expect(wrapper.version).to eq('ruby-5.4.3')
      end

      it "should set @ignore_local_version to the matrix build's value" do
        expect(wrapper.ignore_local_version).to eq(true)
      end
    end

    context 'not a matrix build' do
      before do
        native_build = double Java::HudsonModel::FreeStyleBuild
        expect(native_build).not_to receive(:getBuildVariables)

        build = double
        build.expects(:native) { native_build }

        @wrapper = RbenvWrapper.new build, launcher, listener
        @wrapper.setup
      end

      it 'should not modify @version' do
        expect(wrapper.version).to eq(RbenvDescriptor::DEFAULT_VERSION)
      end

      it 'should not modify @ignore_local_version' do
        expect(wrapper.ignore_local_version).to eq(RbenvDescriptor::DEFAULT_IGNORE_LOCAL_VERSION)
      end
    end

    context 'matrix build is not setting RBENV_VERSION' do
      before do
        native_build = double Java::HudsonMatrix::MatrixRun
        expects(native_build).to receive(:getBuildVariables) { { 'SOME_AXIS' => 'foo' } }

        build = double
        build.expects(:native) { native_build }

        @wrapper = RbenvWrapper.new build, launcher, listener
        @wrapper.setup
      end

      it 'should not modify @version' do
        expect(wrapper.version).to eq(RbenvDescriptor::DEFAULT_VERSION)
      end

      it 'should not modify @ignore_local_version' do
        expect(wrapper.ignore_local_version).to eq(RbenvDescriptor::DEFAULT_IGNORE_LOCAL_VERSION)
      end
    end
  end
end