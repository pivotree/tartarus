class AddLoggedExceptionTable < ActiveRecord::Migration
  def self.up
    create_table :logged_exceptions, :force => true do |t|
      t.string   :group_id
      t.string   :exception_class
      t.string   :controller_path
      t.string   :action_name
      t.text     :message
      t.text     :backtrace
      t.text     :request
      t.datetime :created_at
    end
    add_index :logged_exceptions, :group_id
  end

  def self.down
    drop_table :logged_exceptions
  end
end
