FactoryGirl.define do
  factory :generic_file do
    ignore do
      user {FactoryGirl.create(:user)}
    end
    visibility Sufia::Models::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    file "Sample file"
    batch { FactoryGirl.create(:generic_work, user: user) }
    before(:create) { |file, evaluator|
       file.apply_depositor_metadata(evaluator.user.user_key)
    }
  end
end

