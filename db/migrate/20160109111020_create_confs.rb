class CreateConfs < ActiveRecord::Migration
  def change
    create_table :confs do |t|
      t.integer :exercise_count
      t.string :repository_base

      t.timestamps null: false
    end
  end
end
