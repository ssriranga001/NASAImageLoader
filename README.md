# NASAImageLoader

1. Loading image from server only once per day, if user has already seen once today use same image from cache to show in UI.
2. All the functionalities mentioned in Acceptance Creteria are implemented.
3. For image caching document directory is being used. once api call is being made we are storing those images in document directory
4. For other data caching userdefaults are used.
5. I have followed pure MVVM architecture which this can be unit tested end-to-end since all dependencies are being injected via contructors.

Improvement areas
1. Unit tests casn be added for end-end testing 
2. UI enhancements can be done 
3. API calls can be seggragated at one place
4. Some of constants declared in viewController can be moved to viewModel
