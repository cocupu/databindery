angular.module('curateDeps').factory('BinderyNode', ['$resource', '$location', 'BinderyModel', 'memoService', ($resource, $location, BinderyModel, memoService) ->

  BinderyNode = $resource($location.path().replace("search","nodes")+"/:nodeId", {nodeId:'@persistent_id'}, {
      update: { method: 'PUT' }
  })

  BinderyNode.prototype.download_url = () ->  $location.path().replace("search","file_entities")+"/"+this.persistent_id

  BinderyNode.prototype.model = () ->
    model = memoService.lookup(this.model_id)
    # If model isn't already in memoService cache, load it and cache it.
    # Note: this assumes behavior of being called repeatedly if it returns nil. (which is how the $digest cycle seems to work)
    if (typeof(model) == "undefined")
      BinderyModel.get({modelId: this.model_id}, (data)->
        memoService.createOrUpdate(data)
      )
    return model

  return BinderyNode
])