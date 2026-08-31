class CreateHonorees < ActiveRecord::Migration[ 8.1 ]
  def change
    create_table :honorees do |t|
      t.string :name, null: false
      t.integer :kind, null: false, default: 0
      t.date :birth_date
      t.date :death_date
      t.date :known_from
      t.date :known_until
      t.date :helped_from
      t.date :helped_until
      t.text :honor_inscription
      t.text :body, null: false
      t.string :identifier, null: false
      t.datetime :published_at

      t.timestamps
    end
    add_index :honorees, :identifier, unique: true
    add_index :honorees, :published_at
  end
end

#	20260816162535_create_honorees.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
