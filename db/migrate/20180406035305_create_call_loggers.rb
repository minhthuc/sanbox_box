class CreateCallLoggers < ActiveRecord::Migration[5.1]
  def change
    create_table :call_loggers do |t|
      t.string :callId
      t.string :name
      t.integer :count
      t.timestamps
    end
  end
end
