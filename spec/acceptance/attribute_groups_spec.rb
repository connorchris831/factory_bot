require "spec_helper"
require "acceptance/acceptance_helper"

describe "an instance generated by a factory with multiple attribute groups" do
  before do
    define_model("User", :name => :string, :admin => :boolean, :gender => :string, :email => :string)

    FactoryGirl.define do      
      
      factory :user do
        name "John"

        attribute_group :admin, :factory=>true do
          admin true
        end

        attribute_group :male do
          name   "Joe"
          gender "Male"
        end

        attribute_group :female do
          name   "Jane"
          gender "Female"
        end

        factory :male_user do
          male
        end
        factory :female, :attribute_groups => [:female] do
          attribute_group :admin do
            admin true
            name "Judy"
          end
          factory :female_admin_judy, :attribute_groups=>[:admin]
        end
        factory :female_admin, :attribute_groups => [:female, :admin]
        factory :female_after_male_admin, :attribute_groups => [:male, :female, :admin]
        factory :male_after_female_admin, :attribute_groups => [:female, :male, :admin]
      end
      
      attribute_group :email do
        email { "#{name}@example.com" }
      end
      
      factory :user_with_email, :class=>User, :attribute_groups=>[:email] do
        name "Bill"
      end
      
    end
  end

  context "the parent class" do
    subject      { FactoryGirl.create(:user) }
    its(:name)   { should == "John" }
    its(:gender) { should be_nil }
    it { should_not be_admin }
  end
  
  context "the child class with one attribute group" do
    subject      { FactoryGirl.create(:admin) }
    its(:name)   { should == "John" }
    its(:gender) { should be_nil }
    it { should be_admin }
  end
  
  context "the other child class with one attribute group" do
    subject      { FactoryGirl.create(:female) }
    its(:name)   { should == "Jane" }
    its(:gender) { should == "Female" }
    it { should_not be_admin }
  end
  
  context "the child with multiple attribute groups" do
    subject      { FactoryGirl.create(:female_admin) }
    its(:name)   { should == "Jane" }
    its(:gender) { should == "Female" }
    it { should be_admin }
  end
  
  context "the child with multiple attribute groups and overridden attributes" do
    subject      { FactoryGirl.create(:female_admin, :name => "Jill", :gender => nil) }
    its(:name)   { should == "Jill" }
    its(:gender) { should be_nil }
    it { should be_admin }
  end
  
  context "the child with multiple attribute groups who override the same attribute" do
    context "when the male assigns name after female" do
      subject      { FactoryGirl.create(:male_after_female_admin) }
  
      its(:name)   { should == "Joe" }
      its(:gender) { should == "Male" }
      it { should be_admin }
    end
  
    context "when the female assigns name after male" do
      subject      { FactoryGirl.create(:female_after_male_admin) }
      
      its(:name)   { should == "Jane" }
      its(:gender) { should == "Female" }
      it { should be_admin }
    end
  end
  
  context "child class with scoped attribute group and inherited attribute group" do
    subject { FactoryGirl.create(:female_admin_judy) }
    its(:name) { should == "Judy" }
    its(:gender) { should == "Female" }
    it { should be_admin }
  end
  
  context "factory using global attribute group" do
    subject { FactoryGirl.create(:user_with_email) }
    its(:name) { should == "Bill" }
    its(:email) { should == "Bill@example.com"}
  end
  
  context "factory created from attribute group" do
    subject { FactoryGirl.create(:admin) }
    it { should be_admin }
  end
  
  context "factory created with alternate syntax for specifying attribute group" do
    subject { FactoryGirl.create(:male_user) }
    its(:gender) { should == "Male" }
  end

end
