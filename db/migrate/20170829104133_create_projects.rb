class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :customer_name
      t.decimal :budget
      t.string :technologies, array: true, default: []

      t.timestamps null: false
    end
  end
end
