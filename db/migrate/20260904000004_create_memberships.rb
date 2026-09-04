# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :organization, type: :uuid, null: false, foreign_key: true, index: true
      t.references :user, type: :uuid, null: false, foreign_key: true, index: true
      t.string :role, null: false, default: "salesperson"

      t.timestamps
    end

    add_index :memberships, %i[organization_id user_id], unique: true
    add_index :memberships, :role
  end
end
