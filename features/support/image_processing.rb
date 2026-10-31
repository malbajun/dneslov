Before('@processed_images') do
   # Controller examples assert the completed upload, not an enqueued job.
   # Use Backgrounder's supported synchronous mode, keeping real processors.
   Picture.any_instance.stubs(:process_image_upload).returns(true)
end
