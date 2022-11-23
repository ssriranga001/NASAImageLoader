# NASAImageLoader

Loading image from server only once per day, if user has already seen once today use same image from cache to show in UI.
All the functionalities mentioned in Acceptance Creteria are implemented.
For image caching document directory is being used. once api call is being made we are storing those images in document directory
For other data caching userdefaults are used.
I have followed pure MVVM architecture which this can be unit tested end-to-end since all dependencies are being injected via contructors.
