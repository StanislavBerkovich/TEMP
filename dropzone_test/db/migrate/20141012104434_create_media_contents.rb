class CreateMediaContents < ActiveRecord::Migration
  def change
    create_table :media_contents do |t|
      t.string :file_name

      t.timestamps
    end
  end
end
