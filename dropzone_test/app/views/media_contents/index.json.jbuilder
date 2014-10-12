json.array!(@media_contents) do |media_content|
  json.extract! media_content, :id, :file_name
  json.url media_content_url(media_content, format: :json)
end
