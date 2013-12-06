# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#//= require blueimp-load-image/js/load-image.min
#//= require blueimp-canvas-to-blob/js/canvas-to-blob.min
#//= require jquery-file-upload/js/jquery.iframe-transport
#//= require jquery-file-upload/js/jquery.fileupload
#//= require jquery-file-upload/js/jquery.fileupload-process
#//= require jquery-file-upload/js/jquery.fileupload-image
#//= require jquery-file-upload/js/jquery.fileupload-audio
#//= require jquery-file-upload/js/jquery.fileupload-video
#//= require jquery-file-upload/js/jquery.fileupload-validate
#//= require jquery-file-upload/js/jquery.fileupload-angular

# The actual FileUploadController is defined in the file_entities/new view so that the post URL can be rendered within page load
fileupload = angular.module('fileupload', ['blueimp.fileupload'])

fileupload.config(['$httpProvider', 'fileUploadProvider', ($httpProvider, fileUploadProvider) ->
  delete $httpProvider.defaults.headers.common['X-Requested-With'];

  # Demo settings:
  angular.extend(fileUploadProvider.defaults, {
  # Enable image resizing, except for Android and Opera,
  # which actually support image resizing, but fail to
  # send Blob objects via XHR requests:
    disableImageResize: /Android(?!.*Chrome)|Opera/
    .test(window.navigator.userAgent),
#    maxFileSize: 5000000,
#    acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
  })

])

fileupload.controller('FileDestroyController', ['$scope', '$http', ($scope, $http) ->
  file = $scope.file
  if (file.url)
    file.$state =  () -> return state;
    file.$destroy =  () ->
      state = 'pending';
      return $http({
        url: file.deleteUrl,
        method: file.deleteType
      })
      .then(
          () ->
            state = 'resolved'
            $scope.clear(file)
        ,
        () -> state = 'rejected';
        )

  else if (!file.$cancel && !file._index)
    file.$cancel =  () -> $scope.clear(file)
])