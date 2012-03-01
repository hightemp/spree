require 'spec_helper'

describe Spree::Admin::ImageSettingsController do
  before do
    controller.stub :current_user => Factory(:admin_user)
  end

  context "updating image settings" do
    it "should be able to update paperclip settings" do
      put :update, { :preferences => {
        "attachment_path"        => "foo/bar",
        "attachment_default_url" => "baz/bar"
        }
      }
      Spree::Config[:attachment_path].should == "foo/bar"
      Spree::Config[:attachment_default_url].should == "baz/bar"
    end

    context "paperclip styles" do
      it "should be able to update the paperclip styles" do
        put :update, {  "attachment_styles" => { "thumb" => "25x25>" } }
        updated_styles = ActiveSupport::JSON.decode(Spree::Config[:attachment_styles])
        updated_styles["thumb"].should == "25x25>"
      end

      it "should be able to add a new style" do
        put :update, { "attachment_styles" => { }, "new_attachment_styles" => { "1" => { "name" => "jumbo", "value" => "2000x2000>" } } }
        styles = ActiveSupport::JSON.decode(Spree::Config[:attachment_styles])
        styles["jumbo"].should == "2000x2000>"
      end
    end

    context "amazon s3" do
      it "should be able to update s3 settings" do
        put :update, { :preferences => {
          "use_s3"        => "1",
          "s3_access_key" => "a_valid_key",
          "s3_secret"     => "a_secret",
          "s3_bucket"     => "some_bucket"
          }
        }
        Spree::Config[:use_s3].should be_true
        Spree::Config[:s3_access_key].should == "a_valid_key"
        Spree::Config[:s3_secret].should     == "a_secret"
        Spree::Config[:s3_bucket].should     == "some_bucket"
      end

      context "headers" do
        before(:each) { Spree::Config[:use_s3] = true }

        it "should be able to update the s3 headers" do
          put :update, { :preferences => { "use_s3" => "1" }, "s3_headers" => { "Cache-Control" => "max-age=1111" } }
          headers = ActiveSupport::JSON.decode(Spree::Config[:s3_headers])
          headers["Cache-Control"].should == "max-age=1111"
        end

        it "should be able to add a new header" do
          put :update, { "s3_headers" => { }, "new_s3_headers" => { "1" => { "name" => "Charset", "value" => "utf-8" } } }
          headers = ActiveSupport::JSON.decode(Spree::Config[:s3_headers])
          headers["Charset"].should == "utf-8"
        end
      end
    end
  end
end
