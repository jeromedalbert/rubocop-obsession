class MyClass < ApplicationRecord
  after_create_commit :my_private_method

  def my_public_method
  end

  private

  def my_private_method
  end
end
